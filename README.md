# vscode-langservers-extracted-overlay

A Nix flake overlay that provides [Zed Industries' fork][fork] of
`vscode-langservers-extracted` — the HTML/CSS/JSON/ESLint/Markdown language
servers extracted from VSCode.

The fork's key change is a patched HTML language server that supports
workspace-edit-based HTML tag renaming, a feature required by the
[Zed editor](https://zed.dev).

## How it works

Two packages are provided:

- **`vscode-html-languageservice`** — builds only the HTML server from the Zed
  fork. The HTML server is pre-built and committed at `packages/html/lib/` in
  the fork, so no Babel transpilation is needed.
- **`vscode-langservers-extracted`** — takes the original nixpkgs package as-is
  (CSS/JSON/ESLint/Markdown servers) and replaces only the
  `vscode-html-language-server` symlink with the one from
  `vscode-html-languageservice` via `symlinkJoin`.

This means the CSS, JSON, ESLint, and Markdown servers are always sourced from
the well-tested upstream nixpkgs build; only the HTML server is patched.

---

## Using the overlay

### With flakes — direct package reference

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    vscode-langservers-overlay.url = "github:HuaDeity/vscode-langservers-extracted-overlay";
  };

  outputs = { nixpkgs, vscode-langservers-overlay, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [{
        environment.systemPackages = [
          vscode-langservers-overlay.packages.x86_64-linux.default
        ];
      }];
    };
  };
}
```

### With flakes — overlay (replaces `pkgs.vscode-langservers-extracted`)

Applying the overlay means every package in your set that depends on
`vscode-langservers-extracted` will automatically use the Zed fork's HTML
server.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    vscode-langservers-overlay.url = "github:HuaDeity/vscode-langservers-extracted-overlay";
  };

  outputs = { self, nixpkgs, vscode-langservers-overlay, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      modules = [{
        nixpkgs.overlays = [ vscode-langservers-overlay.overlays.default ];
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
      url = "https://github.com/HuaDeity/vscode-langservers-extracted-overlay/archive/main.tar.gz";
    }))
  ];
}
```

---

## Provided outputs

| Output | Description |
|--------|-------------|
| `packages.<system>.default` | `vscode-langservers-extracted` with Zed's HTML server |
| `packages.<system>.vscode-langservers-extracted` | Same as default, named explicitly |
| `packages.<system>.vscode-html-languageservice` | Only the Zed-patched HTML server |
| `overlays.default` | nixpkgs overlay replacing `pkgs.vscode-langservers-extracted` and adding `pkgs.vscode-html-languageservice` |

Supported systems: `x86_64-linux`, `x86_64-darwin`, `aarch64-linux`, `aarch64-darwin`.

---

## Updating the package version

Run `nix-update` — it handles everything automatically:

```bash
nix run nixpkgs#nix-update -- --flake vscode-html-languageservice
```

This updates `version`, `src.hash`, and `npmDepsHash` in
`pkgs/vscode-html-languageservice.nix` in one step.

---

## Relationship to upstream nixpkgs

The overlay sources its CSS, JSON, ESLint, and Markdown servers directly from
[nixpkgs `vscode-langservers-extracted`][upstream] without modification. Only
the HTML server is replaced.

The `vscode-html-languageservice` package differs from the nixpkgs HTML server
in one way: it is built from `zed-industries/vscode-langservers-extracted`
instead of `hrsh7th/vscode-langservers-extracted`. Zed pre-builds the HTML
server output and commits it at `packages/html/lib/`, so no Babel transpilation
step is required.

[fork]: https://github.com/zed-industries/vscode-langservers-extracted
[upstream]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/vs/vscode-langservers-extracted/package.nix
