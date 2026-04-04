# Combines the original nixpkgs vscode-langservers-extracted with Zed's patched
# HTML language server. The upstream package provides the CSS, JSON, ESLint, and
# Markdown servers; we replace only vscode-html-language-server with the output
# of vscode-html-languageservice.
{
  lib,
  symlinkJoin,
  vscode-langservers-extracted-upstream,
  vscode-html-languageservice,
}:

symlinkJoin {
  name = "vscode-langservers-extracted-${vscode-html-languageservice.version}";

  # Start from the upstream package (css/json/eslint/markdown/html), then
  # replace the html symlink in postBuild.
  paths = [ vscode-langservers-extracted-upstream ];

  postBuild = ''
    rm $out/bin/vscode-html-language-server
    ln -s ${vscode-html-languageservice}/bin/vscode-html-language-server \
          $out/bin/vscode-html-language-server
  '';

  meta = vscode-langservers-extracted-upstream.meta // {
    description = "HTML/CSS/JSON/ESLint/Markdown language servers with Zed's patched HTML server";
    homepage = "https://github.com/zed-industries/vscode-langservers-extracted";
  };
}
