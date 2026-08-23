{ ... }:
{
  # Enable nix flakes by default.
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    trusted-users = [
      "root"
      "@wheel"
      "@admin"
    ];
  };
}
