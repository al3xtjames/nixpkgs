{
  lib,
  stdenv,
  fetchFromGitLab,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icmake";
  version = "13.02.00";

  src = fetchFromGitLab {
    owner = "fbb-git";
    repo = "icmake";
    tag = finalAttrs.version;
    hash = "sha256-1MP3o1RwYPK8k2ziRjyLsYRq0Q0rASVdFeEhD62Oq74=";
    postFetch = ''
      cd $out/icmake/support
      mkdir bobcat support
      tar -xzf bobcat.tgz -C bobcat
      tar -xzf support.tgz -C support
      rm bobcat.tgz support.tgz
    '';
  };

  sourceRoot = "${finalAttrs.src.name}/icmake";

  env.ICMAKE_CPPSTD = "-std=c++26";

  strictDeps = true;

  patches = [
    ./buildscripts-use-cxx.patch
    ./fix-install-paths.patch
    ./icmbuild-use-bindir.patch
    ./buildlib-use-extracted-tarballs.patch
  ];

  postPatch = ''
    patchShebangs .

    substituteInPlace INSTALL.im --replace-fail "usr/" ""
  '';

  configurePhase = ''
    runHook preConfigure

    ./prepare "$out"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ./buildlib "$out"
    ./build all

    runHook postBuild
  '';

  installPhase = ''
    runHook preBuild

    ./install all /

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Program maintenance (make) utility using a C-like grammar";
    homepage = "https://fbb-git.gitlab.io/icmake/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pSub ];
    platforms = platforms.linux;
  };
})
