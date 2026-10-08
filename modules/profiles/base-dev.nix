# Base command-line utilities useful regardless of the project or its language.
#
# These are the everyday inspection and productivity tools that do not belong to
# a particular ecosystem: no editor integration, formatter, or linter is
# required to make them useful. Language-specific and repository-wide tooling
# lives in devTools, nixDev, and rustDev.
#
# The same list is exported for Home Manager, NixOS, and nix-darwin so the tools
# are present whether the configuration runs under a normal user or as root,
# where Home Manager does not apply.

{ ... }:

let
  # The shared set of everyday tools.
  #
  # Defined once so every module class exposes exactly the same utilities and
  # there is a single source of truth for what the base profile provides.
  baseDevPackages =
    pkgs: with pkgs; [
      # Filesystem structure.
      #
      # tree renders directory contents as a graph, giving an at-a-glance
      # view of nesting without opening a file browser.
      tree

      # Everyday file viewing.
      #
      # bat replaces cat with syntax highlighting and git integration,
      # making it easier to read files in the terminal.
      bat

      # Recursive search.
      #
      # ripgrep is fast by default: it respects .gitignore and skips
      # binary files, which suits both code inspection and general lookup.
      ripgrep

      # JSON in and out.
      #
      # jq selects, transforms, and validates JSON from the command line,
      # which is the common interchange format for APIs and tooling.
      jq

      # YAML inspection.
      #
      # yq mirrors jq's role for YAML, the other interchange format used
      # by configuration and manifests.
      yq

      # Compression and archives.
      #
      # zip, unzip, and p7zip cover the common archive formats encountered in
      # day-to-day work.
      zip
      unzip
      p7zip

      # Text processing.
      #
      # fzf provides fuzzy finding for files and command history,
      # while fd is a fast, user-friendly replacement for find.
      fzf
      fd

      # Disk usage.
      #
      # dust shows disk usage with a readable, colour-coded layout,
      # and ncdu adds an interactive browser over those results.
      dust

      # Human-readable directory listing.
      #
      # eza is a modern, colourful replacement for ls.
      eza
    ];
in

{
  flake.modules.homeManager.baseDev =
    { pkgs, ... }:
    {
      home.packages = baseDevPackages pkgs;
    };

  flake.modules.nixos.baseDev =
    { pkgs, ... }:
    {
      environment.systemPackages = baseDevPackages pkgs;
    };

  flake.modules.darwin.baseDev =
    { pkgs, ... }:
    {
      environment.systemPackages = baseDevPackages pkgs;
    };
}
