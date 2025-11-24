{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  darwin,
  pkg-config,
  zstd,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-nextest";
  version = "0.9.151";

  src = fetchFromGitHub {
    owner = "nextest-rs";
    repo = "nextest";
    tag = "cargo-nextest-${finalAttrs.version}";
    hash = "sha256-dSQu45aAZoI1l1YjK5f0RkRJxsQbGRaGhCfFsMuSMXc=";
  };

  # Replace nextest-workspace-hack, otherwise we would still depend on aws-lc
  postPatch = ''
    cat > workspace-hack/Cargo.toml <<EOF
    [package]
    name = "nextest-workspace-hack"
    version = "0.1.0"
    edition.workspace = true
    publish = false
    EOF
  '';

  cargoHash = "sha256-g9nr7TM7VSXnfewSJ6LGTeLmsgKwey/TcWE/hQOHSIA=";

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.dtrace
  ];

  buildInputs = [
    zstd
  ];

  cargoBuildFlags = [
    "-p"
    "cargo-nextest"
  ];
  # Upstream recommends this feature set for distributor builds:
  # https://github.com/nextest-rs/nextest/blob/cargo-nextest-0.9.149/cargo-nextest/Cargo.toml#L63-L65
  buildNoDefaultFeatures = true;
  buildFeatures = [ "default-no-update" ];

  cargoTestFlags = [
    "-p"
    "cargo-nextest"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^cargo-nextest-([0-9.]+)$" ];
  };

  __structuredAttrs = true;

  meta = {
    description = "Next-generation test runner for Rust projects";
    mainProgram = "cargo-nextest";
    homepage = "https://github.com/nextest-rs/nextest";
    changelog = "https://nexte.st/changelog/#${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [
      matthiasbeyer
      chrjabs
      figsoda
    ];
  };
})
