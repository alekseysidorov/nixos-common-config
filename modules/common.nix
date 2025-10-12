# Common nixos/nix-darwin configuration shared between Linux and macOS
{ ... }: {
  # Flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      allow-import-from-derivation = true;
    };
    optimise.automatic = true;
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;
}
