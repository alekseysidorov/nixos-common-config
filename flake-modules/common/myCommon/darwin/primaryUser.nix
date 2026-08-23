{
  config,
  lib,
  ...
}:
let
  cfg = config.myCommon.primaryUser;
in
{
  # Suppress 'Error: HOME is set to "/Users/user" but we expect "/var/empty"'
  config = lib.mkIf (cfg.name != null) {
    system.primaryUser = cfg.name;
    users.users.${cfg.name}.home = cfg.homeDirectory;
  };
}
