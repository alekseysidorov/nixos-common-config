{
  lib,
  rustPlatform,
  fetchCrate,
  aws-lc,
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-fmt-toml";
  version = "0.0.16";
  strictDeps = true;

  buildInputs = [
    aws-lc
  ];

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-H5X3DfCxA5mftbOUj/e5Iv60/sZG3CXcCrsCjOyEzGs=";
  };

  cargoHash = "sha256-iRVcG8bH/b9f+yBRFUyS4ULMwVzeOJZzKGVbfj2rz5M=";

  meta = with lib; {
    description = "Cargo subcommand to format and normalize Cargo.toml layout (section order, sorted dep keys, TOML shape)";
    homepage = "https://github.com/dataroadinc/cargo-fmt-toml";
    license = licenses.cc-by-sa-40;
    mainProgram = "cargo-fmt-toml";
    platforms = platforms.unix;
  };
}
