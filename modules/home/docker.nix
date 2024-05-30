# Fixes against evil corporations.
#
# https://huecker.io
{ config, ... }: 
{
  home.file."${config.xdg.configHome}/docker/daemon.json" = {
    source = ./assets/daemon.json;
  };
}