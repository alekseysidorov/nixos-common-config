{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "cargo-makedocs";
  version = "1.2.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-07eK5LkSbW690ZT6aongIM8uvWHdb2/mz6eUqB3lwt4=";
  };


  cargoSha256 = "sha256-gHpWWPTrY5lcgaFWGbSZ17IPuEJdPSpbYraapCdO1C8=";
  # Doctests fails with an error "doctest failed, to rerun pass `--doc`"
  doCheck = false;

  meta = with lib; {
    description = "Generate markdown comparison tables from cargo-criterion benchmark output";
    homepage = "https://github.com/nu11ptr/criterion-table";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
