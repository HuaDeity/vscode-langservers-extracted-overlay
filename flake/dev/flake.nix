{
  description = "Private inputs for CI/dev — not visible in consumer lock files.";

  inputs = {
    root.url = "path:../..";
    nixpkgs.follows = "root/nixpkgs";
    flake-parts.follows = "root/flake-parts";

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  # This flake is only used for its inputs.
  outputs = _: { };
}
