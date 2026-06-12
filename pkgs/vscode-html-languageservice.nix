{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "vscode-html-languageservice";
  version = "4.10.7";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "vscode-langservers-extracted";
    # Upstream's release workflow creates a release-v* branch but does not
    # reliably push the v* tag (e.g. v4.10.8 was never tagged), so track the
    # release branch instead. The output hash still pins the exact content.
    rev = "release-v${version}";
    hash = "sha256-VpCifcSg7H6d03c/BPeW1bHd7xxGff/V3P4pctcJmDY=";
  };

  npmDepsHash = "sha256-G4KROyE0OPdDCEEcZOvQbM/h7PDaBCkrlOrGIoUJ1TY=";

  # The HTML server is pre-built by Zed and committed at packages/html/lib/.
  # No build step is required.
  dontNpmBuild = true;

  postInstall = ''
    # Only expose the HTML language server; the other servers come from the
    # upstream vscode-langservers-extracted package.
    find $out/bin -name "vscode-*" ! -name "vscode-html-language-server" -delete
  '';

  meta = {
    description = "HTML language server with Zed's workspace-edit tag rename patch";
    homepage = "https://github.com/zed-industries/vscode-langservers-extracted";
    license = lib.licenses.mit;
    mainProgram = "vscode-html-language-server";
  };
}
