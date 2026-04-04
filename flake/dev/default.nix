{ inputs, ... }:
{
  imports = [
    inputs.hercules-ci-effects.flakeModule
    ./ci.nix
    ./checks.nix
  ];
}
