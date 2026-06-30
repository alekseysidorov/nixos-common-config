{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  udev,
  fontconfig,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "comchan";
  version = "0.9.0";
  strictDeps = true;

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-I+Qgbq3fiOT7MWSmoXW0iKMlnrQ6Qe0oJYFR3c5OqCY=";
  };

  cargoHash = "sha256-oLD2Ow/E9UhvKYLXB4kLlguTPeWjDJf0s3UUkCcfVbU=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    udev
    fontconfig
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
