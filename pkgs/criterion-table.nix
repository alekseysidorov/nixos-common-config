{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "criterion-table";
  version = "0.4.2";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-JWJUIgpXCsafWNDnDPC975wQUO0Fb3nUTYmG63jNCiQ=";
  };

  cargoHash = "sha256-92SzUhLuFviIdPt0pfinEQtrDo9MdFQptSJRWPe8qt4=";
  # Doctests fails with an error "doctest failed, to rerun pass `--doc`"
  doCheck = false;

  meta = with lib; {
    description = "Generate markdown comparison tables from cargo-criterion benchmark output";
    homepage = "https://github.com/nu11ptr/criterion-table";
    license = licenses.mit;
    maintainers = [ maintainers.alekseysidorov ];
  };
}
