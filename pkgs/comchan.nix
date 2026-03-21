{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  udev,
}:

rustPlatform.buildRustPackage rec {
  pname = "comchan";
  version = "0.2.6";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-C+DvcXGqqQbkof2+s/Xzz5IL8gW+9VQ3W7reJ9AsZu8=";
  };

  cargoHash = lib.fakeHash;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
  ];

  meta = with lib; {
    description = "A blazingly fast and minimal serial monitor for embedded applications";
    homepage = "https://github.com/Vaishnav-Sabari-Girish/ComChan";
    license = licenses.mit;
    mainProgram = "comchan";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
