final: prev: {
  cargo-fmt-toml = final.callPackage ./cargo-fmt-toml.nix { };
  comchan = final.callPackage ./comchan.nix { };
  vk-turn-proxy = final.callPackage ./vk-turn-proxy.nix { };
}
