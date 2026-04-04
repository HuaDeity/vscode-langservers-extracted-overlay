{
  description = "Nix flake overlay for Zed Industries' fork of vscode-langservers-extracted";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    vscode-langservers-src = {
      url = "github:zed-industries/vscode-langservers-extracted/v4.10.7";
      flake = false;
    };
  };

  # nixConfig = {
  #   extra-substituters = [ "https://zed-vscode-langservers.cachix.org" ];
  #   extra-trusted-public-keys = [ "zed-vscode-langservers.cachix.org-1:..." ];
  # };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          packages = {
            default = pkgs.callPackage ./pkgs/package.nix {
              src = inputs.vscode-langservers-src;
            };
            vscode-langservers-extracted = config.packages.default;
          };
        };

      flake = {
        # Drop-in overlay: replaces pkgs.vscode-langservers-extracted with the
        # Zed fork. Apply via nixpkgs.overlays or pkgs.extend.
        overlays.default =
          final: _prev:
          {
            vscode-langservers-extracted = final.callPackage ./pkgs/package.nix {
              src = inputs.vscode-langservers-src;
            };
          };
      };
    };
}
