{
  config,
  ...
}:
let
  primaryUser = config.myCommon.primaryUser;
in
{
  # Suppress 'Error: HOME is set to "/Users/user" but we expect "/var/empty"'
  system.primaryUser = primaryUser.name;
  users.users.${primaryUser.name}.home = primaryUser.homeDirectory;
}
