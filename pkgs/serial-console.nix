{ lib
, rustPlatform
, fetchCrate
, pkgconf
, systemd
, stdenv
, ...

}:

rustPlatform.buildRustPackage rec {
  pname = "serial-console";
  version = "1.0.1";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-OM0q3f/gRNlR1djZMgDh+Z2YI1L8evCzpFhw9H7272A=";
  };
  cargoHash = "sha256-diMH0ZWD0XVxdsrf63at50qvcTsKaLhPRg64UjZ/FYk=";

  nativeBuildInputs = [ pkgconf ];
  buildInputs = lib.optionals stdenv.isLinux [ systemd ];

  meta = with lib; {
    description = "Serial console CLI utility";
    homepage = "https://crates.io/crates/serial-console";
    license = licenses.mit;
    maintainers = with maintainers; [ alekseysidorov ];
    platforms = platforms.unix;
  };
}
