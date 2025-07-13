{ lib
, rustPlatform
, fetchFromGitHub
, pkgconf
, systemd
, stdenv
, ...
}:

rustPlatform.buildRustPackage {
  pname = "serial-monitor";
  version = "unstable-20250712";

  src = fetchFromGitHub {
    owner = "dhylands";
    repo = "serial-monitor";
    rev = "a43047e55b8069a482370cf3d8cc9f1a822075dc";
    sha256 = "sha256-m9CKBlCQTBMG+95YthLzllSNkKT1/6UxjwET2fujawU=";
  };
  cargoHash = "sha256-BXtrHKK+G/5Hni9Rfpxj3nKlRVabyKDiZiDKpulSX4w=";

  patches = [ ./patches/fix-unwrap-or-default.patch ];

  nativeBuildInputs = [ pkgconf ];
  buildInputs = lib.optionals stdenv.isLinux [ systemd ];

  meta = with lib; {
    description = "Cross platform command line serial terminal program.";
    homepage = "https://crates.io/crates/serial-monitor";
    license = licenses.mit;
    maintainers = with maintainers; [ alekseysidorov ];
    platforms = platforms.unix;
  };
}
