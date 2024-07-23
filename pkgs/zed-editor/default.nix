{
  lib,
  rustPlatform,
  fetchFromGitHub,
  clang,
  copyDesktopItems,
  curl,
  perl,
  pkg-config,
  protobuf,
  xcbuild,
  fontconfig,
  freetype,
  libgit2,
  openssl,
  sqlite,
  zlib,
  zstd,
  alsa-lib,
  libxkbcommon,
  wayland,
  libglvnd,
  xorg,
  stdenv,
  darwin,
  makeFontsConf,
  vulkan-loader,
  envsubst,
  nix-update-script,

  withGLES ? false,
}:

assert withGLES -> stdenv.isLinux;

rustPlatform.buildRustPackage rec {
  pname = "zed";
  version = "0.144.4";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "zed";
    rev = "refs/tags/v${version}";
    hash = "sha256-D4wVHMNy7xESuEORULyKf3ZxFfRSKfWEXjBnjh3yBVU=";
    fetchSubmodules = true;
  };

  cargoHash = "";

  nativeBuildInputs = [
    clang
    copyDesktopItems
    curl
    perl
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ] ++ lib.optionals stdenv.isDarwin [ xcbuild.xcrun ];

  buildInputs =
    [
      curl
      fontconfig
      freetype
      libgit2
      openssl
      sqlite
      zlib
      zstd
    ]
    ++ lib.optionals stdenv.isLinux [
      alsa-lib
      libxkbcommon
      wayland
      xorg.libxcb
    ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        AppKit
        CoreAudio
        CoreFoundation
        CoreGraphics
        CoreMedia
        CoreServices
        CoreText
        Foundation
        IOKit
        Metal
        Security
        SystemConfiguration
        VideoToolbox
      ]
    );

  cargoBuildFlags = [
    "--package=zed"
    "--package=cli"
  ];
  buildFeatures = [ "gpui/runtime_shaders" ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [
        "${src}/assets/fonts/zed-mono"
        "${src}/assets/fonts/zed-sans"
      ];
    };
  };

  RUSTFLAGS = if withGLES then "--cfg gles" else "";
  gpu-lib = if withGLES then libglvnd else vulkan-loader;

  postFixup = lib.optionalString stdenv.isLinux ''
    patchelf --add-rpath ${gpu-lib}/lib $out/libexec/*
    patchelf --add-rpath ${wayland}/lib $out/libexec/*
  '';

  checkFlags = lib.optionals stdenv.hostPlatform.isLinux [
    # Fails on certain hosts (including Hydra) for unclear reason
    "--skip=test_open_paths_action"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec
    cp target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/zed $out/libexec/zed-editor
    cp target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cli $out/bin/zed

    install -D ${src}/crates/zed/resources/app-icon@2x.png $out/share/icons/hicolor/1024x1024@2x/apps/zed.png
    install -D ${src}/crates/zed/resources/app-icon.png $out/share/icons/hicolor/512x512/apps/zed.png

    # extracted from https://github.com/zed-industries/zed/blob/v0.141.2/script/bundle-linux (envsubst)
    # and https://github.com/zed-industries/zed/blob/v0.141.2/script/install.sh (final desktop file name)
    (
      export DO_STARTUP_NOTIFY="true"
      export APP_CLI="zed"
      export APP_ICON="zed"
      export APP_NAME="Zed"
      export APP_ARGS="%U"
      mkdir -p "$out/share/applications"
      ${lib.getExe envsubst} < "crates/zed/resources/zed.desktop.in" > "$out/share/applications/dev.zed.Zed.desktop"
    )

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.*)"
    ];
  };

  meta = {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    homepage = "https://zed.dev";
    changelog = "https://github.com/zed-industries/zed/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      GaetanLepage
      niklaskorz
    ];
    mainProgram = "zed";
    platforms = lib.platforms.all;
    # Currently broken on darwin: https://github.com/NixOS/nixpkgs/pull/303233#issuecomment-2048650618
    broken = stdenv.isDarwin;
  };
}