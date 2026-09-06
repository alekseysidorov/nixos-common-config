{
  writeNuShellApplication,
  git,
  findutils,
}:
writeNuShellApplication {
  name = "git-sweep-all";
  runtimeInputs = [
    git
    findutils
  ];
  text = ''
    # Delete local branches with a gone upstream in a all Git repositories under the given path.
    def main [
      root: path = "." # Repository or root directory to process.
      --this-repo      # Process only given git repository path
    ] {
      let root = ($root | path expand)
      let repos = if not $this_repo {
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
}
