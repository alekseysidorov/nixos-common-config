# Fixes against evil corporations.
#
# https://huecker.io
{ ... }: 
{
  home.file."~/.config/docker/daemon.json".text = builtins.toJSON {
    registry-mirrors = [
      # "https://huecker.io"
      # Let's try to use google mirror.
      "https://mirror.gcr.io"
    ];
  };
}