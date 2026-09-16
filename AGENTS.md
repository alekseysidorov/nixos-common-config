# AGENTS.md

All documentation must be in English. Keep instructions concise.

## Core Properties

When uncertain, optimize for these properties:

1. One semantic value, one source of truth.
2. Facts describe identity; modules describe behavior.
3. Keep transport, routing, NAT, services, and policy orthogonal.
4. Give every responsibility exactly one authority.
5. Ownership follows semantic boundaries and lifetime.
6. Prefer derived values over duplicated state.
7. Keep the normal path simple; make exceptions explicit.
8. Make invalid states difficult to express.
9. Verify runtime invariants before destructive changes.
10. Delete obsolete architecture once its replacement is proven.

These properties are canonical and shared across repositories. The design
principles below are this repository's realization of them.

## Design Principles

- This repository is a reusable personal platform layer, not a machine inventory.
- Keep machine-specific policy in consumers.
- Prefer capabilities over global configuration bags.
- Share semantics; allow platform-specific realization where native APIs differ.
- Prefer explicit model divergence over fake uniform abstractions.
- Presence and activation are different concepts.
- Provider-owned dependencies must stay provider-owned.
- Exported modules must be self-contained.
- Do not rely on hidden overlay or module-argument ordering between unrelated capabilities.
- Use one canonical overlay/package universe; derive lexical local `pkgs` only when needed.
- Module class is part of the type: flake-parts, NixOS, nix-darwin and Home Manager are separate graphs.
- Put decisions at the level where their results live.
- Prefer native module APIs over bypassing them.
- Never materialize secrets as Nix values or store paths; pass only external secret paths.
- Expose semantic interfaces, not implementation artifacts.
- Tests should verify public contracts and resulting behavior, not private layout.
- Keep the core minimal; add new behavior as orthogonal capabilities.
- System modules provide infrastructure.
- Home Manager owns personal UX.
- Practicality is a legitimate tradeoff: take the practical realization over a
  property it fights, and make the deviation explicit. Unrepresentability of
  invalid states is a target, not an absolute.

## Module Structure

Public aggregates:

```text
modules.flake.myCommon
modules.nixos.myCommon
modules.darwin.myCommon
modules.homeManager.myCommon
```

Capabilities contribute to one or more aggregates.

Namespaces:

```text
myCommon.nix.*          Nix policy/infrastructure
myCommon.flake.*        flake-level behavior
myCommon.home.fancy.*   opt-in personal UX/tooling managed by Home Manager
```

Examples:

```text
myCommon.fancy.git.enable
myCommon.fancy.vim.enable
myCommon.fancy.nushell.enable
```

`pkgs/` contains reusable package-set API.

Module-private derivations stay local to their module.

`tests/` verifies public capability contracts and mirrors capability/module-class boundaries where useful.

Consumers own concrete machine composition, users, hosts, hardware, network topology, secrets and other machine-specific policy.

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
specification.

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Common types

- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation changes
- `refactor` — code refactoring (no functional change)
- `chore` — maintenance, tooling, config
- `test` — adding or updating tests

### Rules

- Type is required; scope and breaking-change marker are optional.
- Use a single blank line between the description and the body.
- Describe changes in imperative mood: "fix parsing issue" not "fixed parsing
  issue".
- Commit message title should be <= 72 characters;
