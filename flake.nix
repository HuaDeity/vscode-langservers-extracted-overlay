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
            vscode-html-languageservice = pkgs.callPackage ./pkgs/vscode-html-languageservice.nix {
              src = inputs.vscode-langservers-src;
            };
            vscode-langservers-extracted = pkgs.callPackage ./pkgs/vscode-langservers-extracted.nix {
              vscode-langservers-extracted-upstream = pkgs.vscode-langservers-extracted;
              vscode-html-languageservice = config.packages.vscode-html-languageservice;
            };
            default = config.packages.vscode-langservers-extracted;
          };
        };

      flake = {
        overlays.default =
          final: prev:
          let
            vscode-html-languageservice = final.callPackage ./pkgs/vscode-html-languageservice.nix {
              src = inputs.vscode-langservers-src;
            };
          in
          {
            inherit vscode-html-languageservice;
            vscode-langservers-extracted = final.callPackage ./pkgs/vscode-langservers-extracted.nix {
              vscode-langservers-extracted-upstream = prev.vscode-langservers-extracted;
              inherit vscode-html-languageservice;
            };
          };
      };
    };
}
