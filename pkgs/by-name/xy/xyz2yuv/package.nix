{
  lib,
  buildGoModule,
  fetchFromGitea,
  pkg-config,
  ffmpeg,
  openjpeg,
}:

buildGoModule (finalAttrs: {
  pname = "xyz2yuv";
  version = "0-unstable-2026-02-17";

  src = fetchFromGitea {
    domain = "git.gammaspectra.live";
    owner = "WeebDataHoarder";
    repo = "xyz2yuv";
    rev = "101776004469719f69bfe03fab498399da6f6fab";
    hash = "sha256-nOts2H5OgYmaBnFzM4cA7yCQxSdFWJAHrCxhZt9I9yE=";
  };

  vendorHash = "sha256-WbxVcUwC0N4IDnxFUHPeiftbkVWtU79OldcWPA0ib3w=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    openjpeg
  ];

  doCheck = false;

  meta = {
    description = "Decoder for DCI XYZ' JPEG2000 streams into YUV with colorspace correction";
    homepage = "https://git.gammaspectra.live/WeebDataHoarder/xyz2yuv";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ al3xtjames ];
    mainProgram = "xyz2yuv";
  };
})
