{ lib, stdenv, gnome3, pkgs, wxGTK30, wxGTK31
, gsettings-desktop-schemas, hicolor-icon-theme
, callPackage, callPackages
, librsvg, cups

, pname ? "kicad"
, oceSupport ? false, opencascade
, withOCCT ? true, opencascade-occt
, ngspiceSupport ? true, libngspice
, scriptingSupport ? true, swig, python3, python3Packages
, debug ? false, valgrind
, with3d ? true
, withI18n ? true
}:

assert ngspiceSupport -> libngspice != null;

with lib;
let

  stable = pname != "kicad-unstable";
  baseName = if (stable) then "kicad" else "kicad-unstable";

  versions = {
    "kicad" = {
      kicadVersion = {
        version = "5.1.5";
        src.sha256 = "15h3rwisjss3fdc9bam9n2wq94slhacc3fbg14bnzf4n5agsnv5b";
      };
      libVersion = {
        version = "5.1.5";
        libSources = {
          i18n.sha256 = "1rfpifl8vky1gba2angizlb2n7mwmsiai3r6ip6qma60wdj8sbd3";
          symbols.sha256 = "048b07ffsaav1ssrchw2p870lvb4rsyb5vnniy670k7q9p16qq6h";
          templates.sha256 = "0cs3bm3zb5ngw5ldn0lzw5bvqm4kvcidyrn76438alffwiz2b15g";
          footprints.sha256 = "1c4whgn14qhz4yqkl46w13p6rpv1k0hsc9s9h9368fxfcz9knb2j";
          packages3d.sha256 = "0cff2ms1bsw530kqb1fr1m2pjixyxzwa81mxgac3qpbcf8fnpvaz";
        };
      };
    };
    "kicad-unstable" = {
      kicadVersion = {
        version = "2019-12-28";
        src = {
          rev = "5c0656d97f8ec0826db5048984db1e59716cbcd5";
          sha256 = "1v4nnnl9jsm46na16lzjdcclc66fy5018pl9x9395gbyna8yawq6";
        };
      };
      libVersion = {
        version = "unstable";
        libSources = {
          i18n.rev = "3232cd3820c4aceb1b9be191aca1639de5410118";
          i18n.sha256 = "0mk9f68fifrkp85g7d76qsqa55d3y6wzz2ywl1jbanvxm7xnwa12";
          symbols.rev = "724fe51a619534ce1b0e81679521615f769a7b16";
          symbols.sha256 = "15g70pi6sg6ghpzkv6f6fb5xi65a7v6h72wlqac4n2p40pb3y458";
          templates.rev = "0c0490897f803ab8b7c3dad438b7eb1f80e0417c";
          templates.sha256 = "0cs3bm3zb5ngw5ldn0lzw5bvqm4kvcidyrn76438alffwiz2b15g";
          footprints.rev = "8cef00a34078c3dabe943a76f9cdf7d05ffc38fc";
          footprints.sha256 = "0aplxxbcyb4vpj3kpcnj6lbnpk9zjql46js9i4iaqs388z93sb97";
          packages3d.rev = "58d73640ebb764637eb7bba6290815b84a24b8ad";
          packages3d.sha256 = "0cff2ms1bsw530kqb1fr1m2pjixyxzwa81mxgac3qpbcf8fnpvaz";
        };
      };
    };
  };
  versionConfig = versions.${baseName};

  wxGTK = if (stable)
    # wxGTK3x may default to withGtk2 = false, see #73145
    then wxGTK30.override { withGtk2 = false; }
    # wxGTK31 currently introduces an issue with opening the python interpreter in pcbnew
    # but brings high DPI support?
    else wxGTK31.override { withGtk2 = false; };

  pythonPackages = python3Packages;
  python = python3;
  wxPython = python3Packages.wxPython_4_0;

  kicad-libraries = callPackages ./libraries.nix versionConfig.libVersion;
  kicad-base = callPackage ./base.nix {
    pname = baseName;
    inherit versions stable baseName;
    inherit wxGTK python wxPython;
    inherit debug withI18n withOCCT oceSupport ngspiceSupport scriptingSupport;
  };

in
stdenv.mkDerivation rec {

  inherit pname;
  version = versions.${baseName}.kicadVersion.version;

  src = kicad-base;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  pythonPath = optionals (scriptingSupport)
    [ wxPython pythonPackages.six ];

  nativeBuildInputs = optionals (scriptingSupport)
    [ pythonPackages.wrapPython ];

  # wrapGAppsHook added the equivalent to ${kicad-base}/share
  # though i noticed no difference without it
  makeWrapperArgs = [
    "--prefix XDG_DATA_DIRS : ${kicad-base}/share"
    "--prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share"
    "--prefix XDG_DATA_DIRS : ${gnome3.defaultIconTheme}/share"
    "--prefix XDG_DATA_DIRS : ${wxGTK.gtk}/share/gsettings-schemas/${wxGTK.gtk.name}"
    "--prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
    # wrapGAppsHook did these two as well, no idea if it matters...
    "--prefix XDG_DATA_DIRS : ${cups}/share"
    "--prefix GIO_EXTRA_MODULES : ${gnome3.dconf}/lib/gio/modules"

    "--set KISYSMOD ${kicad-libraries.footprints}/share/kicad/modules"
    "--set KICAD_SYMBOL_DIR ${kicad-libraries.symbols}/share/kicad/library"
    "--set KICAD_TEMPLATE_DIR ${kicad-libraries.templates}/share/kicad/template"
    "--prefix KICAD_TEMPLATE_DIR : ${kicad-libraries.symbols}/share/kicad/template"
    "--prefix KICAD_TEMPLATE_DIR : ${kicad-libraries.footprints}/share/kicad/template"
  ]
  ++ optionals (with3d) [ "--set KISYS3DMOD ${kicad-libraries.packages3d}/share/kicad/modules/packages3d" ]
  ++ optionals (ngspiceSupport) [ "--prefix LD_LIBRARY_PATH : ${libngspice}/lib" ]

  # infinisil's workaround for #39493
  ++ [ "--set GDK_PIXBUF_MODULE_FILE ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" ]
  ;

  # dunno why i have to add $makeWrapperArgs manually...
  # $out and $program_PYTHONPATH don't exist when makeWrapperArgs gets set?
  # not sure if anything has to be done with the other stuff in kicad-base/bin
  # dxf2idf, idf2vrml, idfcyl, idfrect, kicad2step, kicad-ogltest
  installPhase =
    optionalString (scriptingSupport) '' buildPythonPath "${kicad-base} $pythonPath"
    '' +
    '' makeWrapper ${kicad-base}/bin/kicad $out/bin/kicad $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/pcbnew $out/bin/pcbnew $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/eeschema $out/bin/eeschema $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/gerbview $out/bin/gerbview $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/pcb_calculator $out/bin/pcb_calculator $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/pl_editor $out/bin/pl_editor $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    '' +
    '' makeWrapper ${kicad-base}/bin/bitmap2component $out/bin/bitmap2component $makeWrapperArgs ''
    + optionalString (scriptingSupport) '' --set PYTHONPATH "$program_PYTHONPATH"
    ''
  ;

  meta = {
    description = if (stable)
      then "Open Source Electronics Design Automation Suite"
      else "Open Source EDA Suite, Development Build";
    homepage = "https://www.kicad-pcb.org/";
    longDescription = ''
      KiCad is an open source software suite for Electronic Design Automation.
      The Program handles Schematic Capture, and PCB Layout with Gerber output.
    '';
    license = licenses.agpl3;
    # berce seems inactive...
    maintainers = with maintainers; [ evils kiwi berce ];
    # kicad's cross-platform, not sure what to fill in here
    platforms = with platforms; linux;
  };
}
