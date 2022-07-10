{ lib, stdenv, fetchFromGitHub, jdk, jre, ant, autoconf, automake, libtool
, libX11, texinfo
}:

stdenv.mkDerivation rec {
  pname = "jna";
  version = "5.12.1";

  src = fetchFromGitHub {
    owner = "java-native-access";
    repo = "jna";
    rev = version;
    sha256 = "sha256-daKh07G9pLL+3UfiMF0be/LSf9rsGECB/8ALcH9qt1g";
  };

  nativeBuildInputs = [ jdk ant autoconf automake libtool libX11 texinfo ];

  buildPhase = ''
    export LANG=C.UTF-8 # testLoadLibraryWithUnicodeNames needs this
    ant -Drelease=true
  '';

  installPhase = ''
    mkdir -p $out/share/java
    cp -r dist/* $out/share/java
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "Dynamic access of native libraries from Java without JNI";
    homepage = "https://github.com/java-native-access/jna";
    platforms = platforms.unix;
    license = with licenses; [ lgpl21Plus asl20 ];
    maintainers = with maintainers; [ al3xtjames ];
  };
}
