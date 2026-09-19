# Development tools useful across Rust projects.
#
# The exact Rust toolchain and native build dependencies belong to each
# project's configuration. This profile provides user-level tooling that is
# useful independently of a particular repository.
#
# rustfmt, Clippy, and rust-analyzer are intentionally not installed here:
# they should come from the Rust toolchain selected by the project.

{ ... }:

{
  flake.modules.homeManager.rustDev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Rust toolchain manager.
        #
        # Projects may select their own toolchain with rust-toolchain.toml or
        # provide one through a Nix devShell; this profile does not prescribe
        # a particular Rust version.
        rustup

        # Everyday development and inspection.
        #
        # nextest provides a better test runner, while expand makes generated
        # code from macros visible when debugging type-level machinery.
        cargo-nextest
        cargo-expand

        # Manifest and feature hygiene.
        #
        # Keep Cargo.toml files in canonical order and verify crates across
        # their supported feature combinations.
        cargo-sort
        cargo-hack

        # Dependency hygiene and policy.
        #
        # shear finds unused or misplaced dependencies; deny checks dependency
        # policy such as advisories, licenses, bans, and allowed sources.
        cargo-shear
        cargo-deny

        # Coverage and performance analysis.
        #
        # These are intentionally diagnostic tools rather than build-system
        # requirements, so they are useful to have available across projects.
        cargo-llvm-cov
        cargo-bloat
        cargo-flamegraph

        # Public API compatibility.
        #
        # Particularly useful for libraries: detect accidental semver-breaking
        # changes before publishing a new version.
        cargo-semver-checks
      ];
    };
}
