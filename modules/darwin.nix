# nix-darwin specific configuration shared between all machines
{ pkgs, ... }: {
  # security.pam.enableSudoTouchIdAuth = true;

  # Nix configuration parameters
  nix = {
    package = pkgs.nix;
  };

  # Macos specific virtualization 
  # TODO Rewrite closer to NixOS virtualization support
  # https://nixos.wiki/wiki/Docker
  environment.systemPackages = with pkgs; [
    # Docker
    colima
    docker
    # nerdctl wrapper without `colima nerdctl install`
    (writeShellApplication {
      name = "nerdctl";
      runtimeInputs = [ colima ];
      text = ''colima nerdctl -- "$@"'';
    })
  ];
}
