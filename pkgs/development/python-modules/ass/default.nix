{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  replaceVars,
  setuptools,
  libass,
  pillow,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-ass";
  version = "0.5.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chireiden";
    repo = "python-ass";
    tag = version;
    hash = "sha256-q4iZ0WWjioHH4XbbWNr484i+MF5by0IaintQ6W22vBU=";
  };

  patches = [
    (replaceVars ./library-paths.patch {
      libass = "${lib.getLib libass}/lib/libass${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    ./skip-show-in-renderer-test.patch
  ];

  postPatch = ''
    # https://github.com/chireiden/python-ass/commit/22bb6bf85825f7c76f70bb6c249ef17daab8c3d6
    touch tests/__init__.py
    mv _renderer_test.py tests/test_renderer.py
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    libass
  ];

  nativeCheckInputs = [
    pillow
    pytestCheckHook
  ];

  meta = {
    description = "Library for parsing and manipulating Advanced SubStation Alpha subtitle files";
    homepage = "https://github.com/chireiden/python-ass";
    downloadPage = "https://github.com/chireiden/python-ass/releases";
    changelog = "https://github.com/chireiden/python-ass/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ al3xtjames ];
  };
}
