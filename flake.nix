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
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          # easyOverlay reads overlayAttrs and generates overlays.default automatically.
          # pkgs here is the base nixpkgs without our overlay applied, so
          # pkgs.vscode-langservers-extracted is always the upstream package.
          overlayAttrs = {
            inherit (config.packages)
              vscode-html-languageservice
              vscode-langservers-extracted
              ;
          };

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
    };
}
