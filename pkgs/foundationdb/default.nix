{ lib
, gccStdenv
, fetchFromGitHub
  # native deps
, cmake
, ninja
, pkg-config
, mono
, python3
, openjdk8
, git
  # Build deps
, msgpack
, toml11
, boost178
, openssl
  # Other
, pkgsBuildHost
}:

let
  lz4 = pkgsBuildHost.pkgsStatic.lz4;
in
gccStdenv.mkDerivation rec {
  pname = "foundationdb";
  version = "7.1.32";

  src = fetchFromGitHub {
    owner = "apple";
    repo = "foundationdb";
    rev = "refs/tags/${version}";
    hash = "sha256-CNJ4w1ECadj2KtcfbBPBQpXQeq9BAiw54hUgRTWPFzY=";
  };

  patches = [
    ./patches/disable-flowbench.patch
    ./patches/don-t-run-tests-requiring-doctest.patch
  ];

  nativeBuildInputs = [
    git
    cmake
    ninja
    pkg-config
    mono
    python3
    openjdk8
  ];

  buildInputs = [ lz4 msgpack toml11 ];

  # separateDebugInfo = true;
  dontFixCmake = true;

  cmakeFlags = [
      # CMake Error at fdbserver/CMakeLists.txt:332 (find_library):
    # >   Could not find lz4_STATIC_LIBRARIES using the following names: liblz4.a
    "-DSSD_ROCKSDB_EXPERIMENTAL=FALSE"

    # FoundationDB's CMake is hardcoded to pull in jemalloc as an external
    # project at build time.
    "-DUSE_JEMALLOC=FALSE"
    # FIXME: why can't openssl be found automatically?
    "-DOPENSSL_USE_STATIC_LIBS=FALSE"
    "-DOPENSSL_CRYPTO_LIBRARY=${openssl.out}/lib/libcrypto.so"
    "-DOPENSSL_SSL_LIBRARY=${openssl.out}/lib/libssl.so"
  ];

  outputs = [ "out" "dev" "lib" ];

  meta = with lib; {
    description = "Open source, distributed, transactional key-value store";
    homepage = "https://www.foundationdb.org";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    maintainers = with maintainers; [ alekseysidorov ];
  };
}
