{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  udev,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "comchan";
  version = "0.7.0";
  strictDeps = true;

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-HIRsaMASFx/TF250CjBLTM5HdlkWQ/439q54ltONqqk=";
  };

  cargoHash = "sha256-cTcqPhIQGHyK1RQH/19yW/HRBbDPZmk7VxHHZPg0KBY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    udev
  ];

  meta = with lib; {
    description = "A blazingly fast and minimal serial monitor for embedded applications";
    homepage = "https://github.com/Vaishnav-Sabari-Girish/ComChan";
    license = licenses.mit;
    mainProgram = "comchan";
    maintainers = with lib.maintainers; [ alekseysidorov ];
    platforms = platforms.unix;
  };
}
