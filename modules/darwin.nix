# nix-darwin specific configuration shared between all machines
{ pkgs, ... }: {
  # security.pam.enableSudoTouchIdAuth = true;

  # Macos specific virtualization
  # TODO Rewrite closer to NixOS virtualization support
  # https://nixos.wiki/wiki/Docker
  environment.systemPackages = with pkgs; [
    # Docker
    colima
    docker
    skopeo
    # nerdctl wrapper without `colima nerdctl install`
    (writeShellApplication {
      name = "nerdctl";
      runtimeInputs = [ colima ];
      text = ''colima nerdctl -- "$@"'';
    })
  ];
}
