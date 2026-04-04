{
  description = "Nix flake overlay replacing vscode-langservers-extracted's HTML server with Zed Industries' fork";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://huadeity.cachix.org" ];
    extra-trusted-public-keys = [
      "huadeity.cachix.org-1:p5RSl+yBzqtjWQZI3gRpvSd7nZXjtscNVAtb1nDo1As="
    ];
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-parts.flakeModules.partitions
      ];

      # checks and herculesCI live in the dev partition so they do not appear
      # in consumers' lock files.
      partitionedAttrs = {
        checks = "dev";
        herculesCI = "dev";
      };

      partitions.dev = {
        extraInputsFlake = ./flake/dev;
        module = ./flake/dev/default.nix;
      };

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
            vscode-html-languageservice = pkgs.callPackage ./pkgs/vscode-html-languageservice.nix { };
            vscode-langservers-extracted = pkgs.callPackage ./pkgs/vscode-langservers-extracted.nix {
              vscode-langservers-extracted-upstream = pkgs.vscode-langservers-extracted;
              vscode-html-languageservice = config.packages.vscode-html-languageservice;
            };
            default = config.packages.vscode-langservers-extracted;
          };
        };
    };
}
