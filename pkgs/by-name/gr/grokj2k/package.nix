{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cli11,
  exiftool,
  lcms2,
  libjpeg_turbo,
  libhwy,
  libpng,
  libtiff,
  perl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grokj2k";
  version = "20.0.5";

  src = fetchFromGitHub {
    owner = "GrokImageCompression";
    repo = "grok";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JnDOer4+vDqbr22AlxXfPO8vFh8KITugf2fxSCTeP4o=";
  };

  patches = [
    ./support-system-highway.patch
    ./fix-pkgconfig-paths.patch
    ./fix-exiftool-path.patch
  ];

  postPatch = ''
    substituteInPlace src/lib/codec/common/exif.cpp \
      --subst-var-by exiftool ${exiftool}
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    (perl.withPackages (p: [ p.ImageExifTool ]))
  ];

  buildInputs = [
    cli11
    exiftool
    lcms2
    libjpeg_turbo
    libhwy
    libpng
    libtiff
    perl
  ];

  cmakeFlags = [
    (lib.cmakeBool "GRK_BUILD_DCI" true)
    (lib.cmakeBool "GRK_BUILD_JPEG" false)
    (lib.cmakeBool "GRK_BUILD_HIGHWAY" false)
    (lib.cmakeBool "GRK_BUILD_LCMS2" false)
    (lib.cmakeBool "GRK_BUILD_LIBPNG" false)
    (lib.cmakeBool "GRK_BUILD_LIBTIFF" false)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source JPEG 2000 codec";
    homepage = "https://github.com/GrokImageCompression/grok";
    downloadPage = "https://github.com/CLIUtils/CLI11/releases/tag/v${finalAttrs.version}";
    changelog  = "https://github.com/CLIUtils/CLI11/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ al3xtjames ];
    platforms = lib.platforms.unix;
  };
})
