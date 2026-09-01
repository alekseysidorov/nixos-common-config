{ inputs, ... }:

final: prev:
let
  system = prev.stdenv.hostPlatform.system;
in
{
  # Unstable overlay providing newer versions of selected packages.
  unstable = import inputs.nixpkgs-unstable {
    localSystem = system;
    inherit (final) config overlays;
  };

  # Additional packages from flake inputs.
  nufmt = inputs.nufmt.packages.${system}.nufmt;

  # Custom packages.
  comchan = final.unstable.callPackage ./pkgs/comchan.nix { };
  git-clean-all = final.writeNuShellApplication {
    name = "git-clean-all";
    runtimeInputs = [
      final.git
      final.findutils
    ];
    text = ''
      # Clean ignored and untracked files in a Git repository.
      def main [
        root: path = "." # Repository or root directory to process.
        --recursive (-r) # Process every Git repository under root.
      ] {
        let root = ($root | path expand)
        let repos = if $recursive {
          ^find $root -type d -name .git -prune
          | lines
          | each { path dirname }
        } else {
          [$root]
        }

        $repos | each { |repo|
            print $"Cleaning ($repo)"
            ^git -C $repo clean -dxf -e "/.vscode" -e ".idea" -e ".zed" -e ".private" -e ".cargo"
        } | ignore
      }
    '';
  };
  git-sweep-all = final.writeNuShellApplication {
    name = "git-sweep-all";
    runtimeInputs = [
      final.git
      final.findutils
    ];
    text = ''
      # Delete local branches with a gone upstream in a Git repository.
      def main [
        root: path = "." # Repository or root directory to process.
        --recursive (-r) # Process every Git repository under root.
      ] {
        let root = ($root | path expand)
        let repos = if $recursive {
          ^find $root -type d -name .git -prune
          | lines
          | each { path dirname }
        } else {
          [$root]
        }

        $repos | each { |repo|
            print $"Sweeping ($repo)"
            ^git -C $repo fetch -p

            ^git -C $repo for-each-ref --format "%(refname) %(upstream:track)" refs/heads
            | lines
            | where { str ends-with "[gone]" }
            | each { |branch|
                let name = ($branch | split row " " | first | str replace "refs/heads/" "")
                ^git -C $repo branch -D $name
              }
        } | ignore
      }
    '';
  };

  # Preserve the common overlay API; the implementation lives in rust-dev-flake.
  inherit (inputs.rust-dev-flake.overlays.default final prev)
    writeNuShellApplication
    writeNuShellScript
    ;
}
