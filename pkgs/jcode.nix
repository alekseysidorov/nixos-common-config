{
  lib,
  stdenv,
  fetchurl,
  openssl,
  autoPatchelfHook ? null,
  libxcb ? null,
  libX11 ? null,
  zlib ? null,
}:

let
  version = "0.99.1";
  system = stdenv.hostPlatform.system;

  releases = {
    x86_64-linux = {
      asset = "jcode-linux-x86_64";
      hash = "0b2a612de97c6e01ae6de1c0cff555b3460cf8364d1a11d2f8649fc0c9d7a1e6";
    };
    aarch64-linux = {
      asset = "jcode-linux-aarch64";
      hash = "f66ffbaf7c4c0124f45d6c8616571146deb8509b8beef2e8c0d76cc35dda9b91";
    };
    x86_64-darwin = {
      asset = "jcode-macos-x86_64";
      hash = "d7d53c40b1e105926e06df5aa02c0f082616d602bbd20e0c318248ce3fdad4c9";
    };
    aarch64-darwin = {
      asset = "jcode-macos-aarch64";
      hash = "3623164d518b0c9d443ab07052084244b379e8a3377037db67d2382220f4ed14";
    };
  };

  release =
    if builtins.hasAttr system releases then
      releases.${system}
    else
      throw "jcode ${version} is not available for ${system}";

  linux = stdenv.hostPlatform.isLinux;
in
stdenv.mkDerivation {
  pname = "jcode";
  inherit version;

  src = fetchurl {
    name = "${release.asset}.tar.gz";
    url = "https://github.com/1jehuang/jcode/releases/download/v${version}/${release.asset}.tar.gz";
    sha256 = release.hash;
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = lib.optionals linux [ autoPatchelfHook ];
  buildInputs = [
    openssl
  ]
  ++ lib.optionals linux [
    libxcb
    libX11
    zlib
  ];

  installPhase = ''
    runHook preInstall

    tar -xzf "$src" -C "$TMPDIR"
    install -Dm755 "$TMPDIR/${release.asset}" "$out/bin/jcode"

    if [ -f "$TMPDIR/${release.asset}.bin" ]; then
      install -Dm755 "$TMPDIR/${release.asset}.bin" "$out/lib/${release.asset}.bin"
    fi

    for library in "$TMPDIR"/libssl.so* "$TMPDIR"/libcrypto.so*; do
      [ -f "$library" ] || continue
      install -Dm755 "$library" "$out/lib/$(basename "$library")"
    done

    runHook postInstall
  '';

  postFixup = lib.optionalString linux ''
    patchelf --add-rpath '$ORIGIN/../lib' "$out/bin/jcode"
    if [ -f "$out/lib/${release.asset}.bin" ] && patchelf --print-rpath "$out/lib/${release.asset}.bin" >/dev/null 2>&1; then
      patchelf --add-rpath '$ORIGIN' "$out/lib/${release.asset}.bin"
    fi
  '';

  meta = {
    description = "High-performance coding agent harness";
    homepage = "https://jcode.sh";
    license = lib.licenses.mit;
    mainProgram = "jcode";
    platforms = builtins.attrNames releases;
  };
}
