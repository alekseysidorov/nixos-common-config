# Fixes against evil corporations.
{ ... }: 
{
  home.file."~/.config/docker/daemon.json".source = builtins.toJSON {
    registry-mirrors = [
      # "https://huecker.io"
      # Let's try to use google mirror.
      "https://mirror.gcr.io"
    ];
  };
}