{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  openssl,
  spdlog,
  ctestCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sgx-tdx-dcap-qvl";
  version = "1.1.8886";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "SGX-TDX-DCAP-QuoteVerificationLibrary";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1YVwdwxAtzeOZEg3GCFGE62WC1L29n7oWYZ2Cj8qJCA=";
  };

  sourceRoot = "${finalAttrs.src.name}/Src";

  patches = [
    ./drop-hunter.patch
    ./darwin-drop-unsupported-flags.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gtest
    openssl
    spdlog
  ];

  doCheck = true;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  # Currently fails?
  disabledTests = [
    "AttestationParsers_UT"
    "PckCertificateUT.unknownTypeCertificateGetters"
  ];

  postInstall = ''
    mkdir -p $out/bin
    cp ../Build/Release/dist/bin/AttestationApp $out/bin
    cp -r ../Build/Release/dist/{include,lib} $out
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reference implementation of ECDSA-based SGX Quote verification";
    homepage = "https://github.com/intel/SGX-TDX-DCAP-QuoteVerificationLibrary";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ al3xtjames ];
    mainProgram = "AttestationApp";
    platforms = lib.platforms.all;
  };
})
