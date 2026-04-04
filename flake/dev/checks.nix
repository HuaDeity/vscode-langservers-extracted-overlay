{ ... }:
{
  perSystem =
    { config, ... }:
    {
      checks = {
        inherit (config.packages) vscode-html-languageservice vscode-langservers-extracted;
      };
    };
}
