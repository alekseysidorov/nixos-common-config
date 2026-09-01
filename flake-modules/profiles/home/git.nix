{ ... }:
{
  myCommon.enableGitIntegration = true;

  programs.git.settings.user = {
    name = "Aleksey Sidorov";
    email = "sauron1987@gmail.com";
  };
}
