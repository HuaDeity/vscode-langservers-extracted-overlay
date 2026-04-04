# HTML language server from Zed Industries' fork of vscode-langservers-extracted.
#
# The HTML server is pre-built and committed at packages/html/lib/ in the fork,
# so no Babel transpilation is needed. We only expose vscode-html-language-server
# and drop the other bins (css/json/eslint/markdown) which come from the original
# nixpkgs vscode-langservers-extracted.
#
# Hashes that need updating when bumping the version:
#   • vscode-langservers-src input  – update the tag in flake.nix and run
#                                     `nix flake update`
#   • npmDepsHash  – set to `lib.fakeHash`, run
#                    `nix build .#vscode-html-languageservice 2>&1 | grep "got:"`,
#                    paste result

{
  lib,
  buildNpmPackage,
  src,
}:

buildNpmPackage {
  pname = "vscode-html-languageservice";
  version = "4.10.7";

  inherit src;

  npmDepsHash = "sha256-G4KROyE0OPdDCEEcZOvQbM/h7PDaBCkrlOrGIoUJ1TY=";

  # The HTML server is pre-built by Zed at packages/html/lib/; skip npm build.
  dontNpmBuild = true;

  postInstall = ''
    # Only expose the HTML language server; the other servers come from the
    # upstream vscode-langservers-extracted package.
    find $out/bin -name "vscode-*" ! -name "vscode-html-language-server" -delete
  '';

  meta = with lib; {
    description = "HTML language server with Zed's workspace-edit tag rename patch";
    homepage = "https://github.com/zed-industries/vscode-langservers-extracted";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "vscode-html-language-server";
  };
}
