{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  replaceVars,
  uv-build,
  libass,
  pillow,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-ass";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chireiden";
    repo = "python-ass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-30QlWhGxMHK6PzsKlHFw4jCksKWYuDm1pm0cTga6lvw=";
  };

  patches = [
    (replaceVars ./library-paths.patch {
      libass = "${lib.getLib libass}/lib/libass${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    ./skip-show-in-renderer-test.patch
  ];

  postPatch = ''
    mv _renderer_test.py tests/test_renderer.py
  '';

  build-system = [
    uv-build
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
    downloadPage = "https://github.com/chireiden/python-ass/releases/tag/v${finalAttrs.version}";
    changelog = "https://github.com/chireiden/python-ass/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ al3xtjames ];
  };
})
