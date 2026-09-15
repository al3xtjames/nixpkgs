{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  nix-update-script,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maki";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "tontinton";
    repo = "maki";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mJFvNpbtYPb0wSsHvKYGFnk48tK5L9vVGg9elzEgXRA=";
  };

  cargoHash = "sha256-l8Lu+7hQzZ9D5Vhs0R+0J6EtgO07UM/9IeAy/224zaU=";

  __structuredAttrs = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  env.OPENSSL_NO_VENDOR = true;

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An efficient AI coding agent extendable by neovim-like Lua plugins";
    homepage = "https://maki.sh/";
    downloadPage = "https://github.com/tontinton/maki/releases/tag/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ al3xtjames ];
    mainProgram = "maki";
  };
})
