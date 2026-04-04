# zed-vscode-langservers-overlay

A Nix flake overlay that packages [Zed Industries' fork][fork] of
`vscode-langservers-extracted` — the HTML/CSS/JSON/ESLint language servers
extracted from VSCode.

The fork's key customisation is a patched HTML language server that supports
workspace-edit-based HTML tag renaming, a feature required by the
[Zed editor](https://zed.dev).

---

## Using the overlay

### With flakes — direct package reference

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zed-vscode-langservers.url = "github:HuaDeity/zed-vscode-langservers-overlay";
  };

  outputs = { nixpkgs, zed-vscode-langservers, ... }: {
    # Example: NixOS system configuration
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          zed-vscode-langservers.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

### With flakes — overlay (replaces `pkgs.vscode-langservers-extracted`)

Applying the overlay means every package in your set that depends on
`vscode-langservers-extracted` will automatically use the Zed fork.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zed-vscode-langservers.url = "github:HuaDeity/zed-vscode-langservers-overlay";
  };

  outputs = { self, nixpkgs, zed-vscode-langservers, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [{
        nixpkgs.overlays = [ zed-vscode-langservers.overlays.default ];
      }];
    };
  };
}
```

### Without flakes

```nix
# configuration.nix or home.nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/YOUR_ORG/zed-vscode-langservers-overlay/archive/main.tar.gz";
    }))
  ];
}
```

---

## Provided outputs

| Output | Description |
|--------|-------------|
| `packages.<system>.default` | The Zed fork of `vscode-langservers-extracted` |
| `packages.<system>.vscode-langservers-extracted` | Same package, named explicitly |
| `overlays.default` | nixpkgs overlay replacing `pkgs.vscode-langservers-extracted` |

Supported systems: `x86_64-linux`, `x86_64-darwin`, `aarch64-linux`, `aarch64-darwin`.

---

## Updating the package version

1. Update the `vscode-langservers-src` input tag in `flake.nix`:
   ```
   url = "github:zed-industries/vscode-langservers-extracted/vX.Y.Z";
   ```
2. Run `nix flake update` to refresh `flake.lock`.
3. Update `version` in `pkgs/package.nix` to match.
4. Recompute the `npmDepsHash`:
   - Set `npmDepsHash = lib.fakeHash;` in `pkgs/package.nix`.
   - Run `nix build .#default 2>&1 | grep "got:"` and paste the printed hash.

---

## Relationship to upstream nixpkgs

This package is derived from
[`pkgs/by-name/vs/vscode-langservers-extracted/package.nix`][upstream]
in nixpkgs with the following changes:

- **Source**: `zed-industries/vscode-langservers-extracted` instead of
  `hrsh7th/vscode-langservers-extracted`.
- **HTML server**: Zed pre-builds and commits the HTML server output at
  `packages/html/lib/` in the fork.  The Babel transpilation step for HTML is
  therefore skipped.
- **Markdown server**: Added — built from VSCodium's
  `markdown-language-features` extension (same Babel approach as CSS/JSON).
- **Package layout**: The fork's `package.json` lists `packages/` (not `lib/`)
  in `files`; a `postPatch` step adds `lib/` so `npm pack` includes the
  built CSS/JSON/ESLint/Markdown servers.

[fork]: https://github.com/zed-industries/vscode-langservers-extracted
[upstream]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/vs/vscode-langservers-extracted/package.nix
