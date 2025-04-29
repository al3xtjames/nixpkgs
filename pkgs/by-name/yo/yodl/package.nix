{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch2,
  icmake,
  perl,
  util-linux,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yodl";
  version = "4.04.00";

  src = fetchFromGitLab {
    owner = "fbb-git";
    repo = "yodl";
    tag = finalAttrs.version;
    hash = "sha256-jzXTHUoCHKyD517eKM3T6WtyN/he138a3WiKChTPS2E=";
  };

  sourceRoot = "${finalAttrs.src.name}/yodl";

  strictDeps = true;

  nativeBuildInputs = [
    icmake
    perl
  ];

  patches = [
    ./add-missing-includes.patch
    ./fix-install-symlinks.patch
    ./replace-getopt.patch
  ];

  postPatch = ''
    patchShebangs .
    patchShebangs macros/rawmacros
    patchShebangs scripts

    substituteInPlace INSTALL.im \
      --replace-fail "/usr" "$out" \
      --replace-fail "gcc" "$CC" \
      --replace-fail "g++" "$CXX"

    substituteInPlace scripts/yodl2whatever.in \
      --subst-var-by "getopt" "${lib.getBin util-linux}/bin/getopt"
  '';

  buildPhase = ''
    runHook preBuild

    ./build programs
    ./build macros
    ./build man

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ./build install programs /
    ./build install macros /
    ./build install man /

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Package that implements a pre-document language and tools to process it";
    homepage = "https://fbb-git.gitlab.io/yodl/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pSub ];
    platforms = platforms.linux;
  };
})
