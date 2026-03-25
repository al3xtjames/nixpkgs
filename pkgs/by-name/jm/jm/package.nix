{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jm";
  version = "19.1";

  src = fetchFromGitLab {
    domain = "vcgit.hhi.fraunhofer.de";
    owner = "jvet";
    repo = "JM";
    rev = "JM-${finalAttrs.version}";
    hash = "sha256-NYAkXwRSmRk9RCF63nDkdC3RrqbAeXVDQOorqyhec8M=";
  };

  patches = [
    ./cmake-non-x86-compat.patch
    (fetchpatch {
      url = "https://vcgit.hhi.fraunhofer.de/jvet/JM/-/commit/429d40bf8e35efbb04cd57932ee51aa6ab6670b9.patch";
      hash = "sha256-+g4PglBN+HBBi7loCZbokNij4j3KzzWTB1l+20EamHw=";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  env.NIX_CFLAGS_COMPILE = builtins.toString [
    "-Wno-bitwise-instead-of-logical"
    "-Wno-implicit-const-int-float-conversion"
    "-Wno-misleading-indentation"
    "-Wno-unused-but-set-variable"
  ];

  installPhase = ''
    runHook preInstall

    install -D ../bin/umake/*/*/release/* -t $out/bin
    # TODO: Copy cfg to $out/share?

    runHook postInstall
  '';

  meta = {
    description = "H.264/AVC JM reference software";
    homepage = "https://avc.hhi.fraunhofer.de/";
    downloadPage = "https://vcgit.hhi.fraunhofer.de/jvet/JM/-/releases/JM-${finalAttrs.version}";
    changelog = "https://vcgit.hhi.fraunhofer.de/jvet/JM/-/blob/JM-${finalAttrs.version}/CHANGES.TXT";
    license = [
      {
        fullName = "ISO/IEC 14496-10 License";
        url = "https://vcgit.hhi.fraunhofer.de/jvet/JM/-/blob/master/COPYRIGHT_ISO_IEC.txt";
      }
      {
        fullName = "ITU License";
        url = "https://vcgit.hhi.fraunhofer.de/jvet/JM/-/blob/master/COPYRIGHT_ITU.txt";
      }
    ];
    platforms = lib.platforms.unix;
  };
})
