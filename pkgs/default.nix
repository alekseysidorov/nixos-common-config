final: prev: {
  comchan = final.callPackage ./comchan.nix { };
  vk-turn-proxy = final.callPackage ./vk-turn-proxy.nix { };
}
