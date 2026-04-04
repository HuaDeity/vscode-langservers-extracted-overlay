# Packaging for Zed Industries' fork of vscode-langservers-extracted.
#
# Key differences from the upstream nixpkgs package (pkgs/by-name/vs/vscode-langservers-extracted):
#
#   1. The HTML language server is patched with Zed-specific changes and its
#      compiled output is committed directly to the fork at packages/html/lib/.
#      We therefore skip the Babel transpilation step for HTML and rely on the
#      pre-built files already present in the source tree.
#
#   2. VSCodium is unpacked in a separate derivation and referenced as a store
#      path in the buildPhase.  This avoids passing the zip as a second source
#      to buildNpmPackage, which would break the npm-deps hash-computation
#      phase (it cannot unzip without the right nativeBuildInputs).
#
#   3. Because the fork's package.json only lists `packages/` and `bin/` in the
#      `files` array, a postPatch step adds `lib/` so that `npm pack` includes
#      the CSS / JSON / ESLint / Markdown servers built in the buildPhase.
#
#   4. The fork adds a `vscode-markdown-language-server` binary; its server
#      files are built from VSCodium's markdown-language-features extension.
#
# Hashes that need updating when bumping the version:
#   • vscode-langservers-src input  – update the tag in flake.nix and run
#                                     `nix flake update`
#   • npmDepsHash  – set to `lib.fakeHash`, run
#                    `nix build .#default 2>&1 | grep "got:"`, paste result

{
  lib,
  stdenv,
  buildNpmPackage,
  src,
  unzip,
  vscodium,
  vscode-extensions,
}:

let
  # Unpack only the bundled extensions from the VSCodium binary distribution.
  # Doing this in a separate derivation keeps buildNpmPackage's src clean (no
  # zip in srcs) so the npm-deps fixed-output derivation can be fetched without
  # needing unzip in its build environment.
  vscodiumExtensions = stdenv.mkDerivation {
    name = "vscodium-extensions-${vscodium.version}";
    src = vscodium.src;
    nativeBuildInputs = [ unzip ];
    dontBuild = true;
    # After unpackPhase, the working directory is the source root.
    # On Darwin the zip's top-level is VSCodium.app, so the unpack sets
    # sourceRoot = "VSCodium.app" and we are already inside it.
    # On Linux the zip/tar's top-level is different; adjust if needed.
    installPhase =
      if stdenv.hostPlatform.isDarwin then
        ''
          cp -r Contents/Resources/app/extensions $out
        ''
      else
        ''
          cp -r resources/app/extensions $out
        '';
  };
in

buildNpmPackage {
  pname = "vscode-langservers-extracted";

  # Keep in sync with the `vscode-langservers-src` input tag in flake.nix.
  version = "4.10.7";

  inherit src;

  # Override the package.json `files` array so that `npm pack` (run by
  # buildNpmPackage's installPhase) includes the `lib/` directory we populate
  # during the buildPhase.
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"packages/",' '"packages/", "lib/",'
  '';

  # Pre-fetched npm dependency tree.  Recompute whenever package-lock.json
  # changes by temporarily setting this to `lib.fakeHash` and running the
  # build; Nix will print the correct hash in the error output.
  npmDepsHash = "sha256-G4KROyE0OPdDCEEcZOvQbM/h7PDaBCkrlOrGIoUJ1TY=";

  buildPhase = ''
    runHook preBuild

    # ── CSS ──────────────────────────────────────────────────────────────────
    npx babel ${vscodiumExtensions}/css-language-features/server/dist/node \
      --out-dir lib/css-language-server/node/

    # ── JSON ─────────────────────────────────────────────────────────────────
    npx babel ${vscodiumExtensions}/json-language-features/server/dist/node \
      --out-dir lib/json-language-server/node/

    # ── Markdown ─────────────────────────────────────────────────────────────
    # The zed fork ships bin/vscode-markdown-language-server but marks it "Not
    # yet" in its README.  VSCodium's markdown-language-features extension is a
    # UI extension without a server/dist/node tree, so it cannot be processed
    # the same way as css/json.  This server is intentionally skipped; the bin
    # wrapper will fail at runtime until Zed completes the implementation.

    # ── ESLint ───────────────────────────────────────────────────────────────
    cp -r \
      ${vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out \
      lib/eslint-language-server

    # ── HTML ─────────────────────────────────────────────────────────────────
    # The HTML server is pre-built by Zed and committed at packages/html/lib/.
    # The bin/vscode-html-language-server wrapper already points there, so
    # nothing extra is required.

    runHook postBuild
  '';

  meta = with lib; {
    description = "HTML/CSS/JSON/ESLint language servers extracted from vscode (Zed Industries fork)";
    longDescription = ''
      A Zed Industries fork of hrsh7th/vscode-langservers-extracted.  The HTML
      language server is patched to support workspace-edit-based tag renaming
      required by Zed's editor.  All other servers (CSS, JSON, ESLint) are
      identical to the upstream extraction.
    '';
    homepage = "https://github.com/zed-industries/vscode-langservers-extracted";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "vscode-html-language-server";
  };
}
