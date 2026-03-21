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
  version = "0.2.6";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-A66sn6oBOIp3WSUo5uY4HeAxpjCphbsHHadEjS0v5Sw=";
  };

  cargoHash = "sha256-xu0z5VP+xxc+sZmys+LNRy28Xw7+kMK37MSf7PvQU4E=";

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
    maintainers = with maintainers; [ alekseysidorov ];
    platforms = platforms.unix;
  };
}
