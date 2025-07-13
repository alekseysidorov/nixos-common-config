{ lib
, rustPlatform
, fetchCrate
, pkgconf
, systemd
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "serial-monitor";
  version = "0.0.7";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-66NY9os7xEYnBDodHT9XZiYZfJ2ZzcFECADgvS2kEOw=";
  };
  cargoHash = "sha256-f0QSbP7+x5tHJyIJ07VcfRHDET1CBZ9N3fMgY09CFI8=";

  patches = [ ./patches/serial-monitor-fix-panic.patch ];

  nativeBuildInputs = [ pkgconf ];
  buildInputs = [ systemd ];

  meta = with lib; {
    description = "Cross platform command line serial terminal program.";
    homepage = "https://crates.io/crates/serial-monitor";
    license = licenses.mit;
    maintainers = with maintainers; [ alekseysidorov ];
    platforms = platforms.linux;
  };
}
