{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "criterion-table";
  version = "0.2.2";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-Rq0GG8dEBx93F7cE8KvAU9BStgeNZWtKMRF8jLMQEes=";
  };


  cargoSha256 = "sha256-L3bvKs/1mf3wtKV9WQS7UM1JMyWa6mj7FGjgJQFJTio=";
  # Doctests fails with an error "doctest failed, to rerun pass `--doc`"
  doCheck = false;

  meta = with lib; {
    description = "Generate markdown comparison tables from cargo-criterion benchmark output";
    homepage = "https://github.com/nu11ptr/criterion-table";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
