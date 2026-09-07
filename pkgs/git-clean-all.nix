{
  writeNushellApplication,
  git,
  findutils,
}:

writeNushellApplication {
  name = "git-clean-all";
  runtimeInputs = [
    git
    findutils
  ];

  text = ''
    # Clean ignored and untracked files in an all Git repositories under the given path.
    def main [
      root: path = "." # Repository or root directory to process.
      --this-repo # Process only repository in the given path
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
          print $"Cleaning ($repo)"
          ^git -C $repo clean -dxf -e "/.vscode" -e ".idea" -e ".zed" -e ".private" -e ".cargo"
      } | ignore
    }
  '';
}
