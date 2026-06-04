final: prev: {
  cargo-fmt-toml = final.callPackage ./cargo-fmt-toml.nix { };
  comchan = final.callPackage ./comchan.nix { };
  vk-turn-proxy = final.callPackage ./vk-turn-proxy.nix { };

  # I want to use fresh ollama, but I cannot override its version.
  ollama = final.callPackage (builtins.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/6432d78bff4d326d5dc2a26b46a4091b530c437e/pkgs/by-name/ol/ollama/package.nix";
    sha256 = "sha256:0zl48wkaxw91di5zb07mjar8ja1s70rx2mwpp7l7alxbm12npdni";
  }) { };
  ollama-rocm = final.ollama.override { acceleration = "rocm"; };
  ollama-vulkan = final.ollama.override { acceleration = "vulkan"; };
}
