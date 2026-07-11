{
  lib,
  stdenv,
  llvmPackages_22,
  cmake,
  ninja,
  gtest,
  fetchFromGitHub,
  nix-update-script,
}:

let
  # Use Clang 22 to avoid a compilation issue with BF16 on AArch64:
  # https://github.com/llvm/llvm-project/issues/159772
  stdenv' =
    if stdenv.cc.isClang && stdenv.hostPlatform.isAarch64 then llvmPackages_22.stdenv else stdenv;
in
stdenv'.mkDerivation (finalAttrs: {
  pname = "libhwy";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "highway";
    rev = finalAttrs.version;
    hash = "sha256-YUYZO9KLffczjwIz3mBBceD6oM1giLCFLDHgDCevdRA=";
  };

  hardeningDisable = lib.optionals stdenv.hostPlatform.isAarch64 [
    # aarch64-specific code gets:
    # __builtin_clear_padding not supported for variable length aggregates
    "trivialautovarinit"
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  # Required for case-insensitive filesystems ("BUILD" exists)
  dontUseCmakeBuildDir = true;

  cmakeFlags =
    let
      libExt = stdenv.hostPlatform.extensions.library;
    in
    [
      "-GNinja"
      "-DCMAKE_INSTALL_LIBDIR=lib"
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
    ]
    ++ lib.optionals finalAttrs.doCheck [
      "-DHWY_SYSTEM_GTEST:BOOL=ON"
      "-DGTEST_INCLUDE_DIR=${lib.getDev gtest}/include"
      "-DGTEST_LIBRARY=${lib.getLib gtest}/lib/libgtest${libExt}"
      "-DGTEST_MAIN_LIBRARY=${lib.getLib gtest}/lib/libgtest_main${libExt}"
    ]
    ++ lib.optionals stdenv.hostPlatform.isAarch32 [
      "-DHWY_CMAKE_ARM7=ON"
    ]
    ++ lib.optionals stdenv.hostPlatform.isx86_32 [
      # Quoting CMakelists.txt:
      #   This must be set on 32-bit x86 with GCC < 13.1, otherwise math_test will be
      #   skipped. For GCC 13.1+, you can also build with -fexcess-precision=standard.
      # Fixes tests:
      #   HwyMathTestGroup/HwyMathTest.TestAllAtanh/EMU128
      #   HwyMathTestGroup/HwyMathTest.TestAllLog1p/EMU128
      "-DHWY_CMAKE_SSE2=ON"
    ]
    ++ lib.optionals stdenv.hostPlatform.isRiscV [
      # Runtime dispatch is not implemented https://github.com/google/highway/issues/838
      # so tests (and likely normal operation) fail with SIGILL on processors without V.
      # Until the issue is resolved, we disable RVV completely.
      "-DHWY_CMAKE_RVV=OFF"
    ];

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Performance-portable, length-agnostic SIMD with runtime dispatch";
    homepage = "https://github.com/google/highway";
    downloadPage = "https://github.com/google/highway/releases";
    changelog = "https://github.com/google/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      asl20
      bsd3
    ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
})
