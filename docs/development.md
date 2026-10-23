# Development and package structure

This repository is the **neutral source template**, not an installable private
plugin by itself. Every installer registers their own SVGator MCP App in ChatGPT
and generates a personalized ZIP locally. Never commit or distribute that ZIP.

## Source layout

| Path | Purpose |
| --- | --- |
| `plugin.json` | Root plugin metadata and OpenAI App reference declaration |
| `.codex-plugin/plugin.json` | Compatibility metadata for plugin import |
| `skills/svgator-animate/` | SVGator animation authoring and editing guidance |
| `skills/svgator-setup/` | Read-only SVGator authentication verification |
| `assets/cfmoon-svgator-animations.png` | Proprietary CFMoon plugin icon |
| `assets/signal-strike-demo.gif` | README demonstration, not packaged in the private ZIP |
| `scripts/prepare-chatgpt-plugin.sh` | Generates the personalized private ZIP |
| `scripts/test-package.sh` | Portable manifest, safety and build contract tests |
| `flake.nix` | Nix developer shell and the same reproducible test suite |
| `.github/workflows/validate.yml` | CI for pull requests and changes to `main` |

The build script always packages these **eight files**, and no others:

```text
plugin.json
.app.json
.codex-plugin/plugin.json
assets/cfmoon-svgator-animations.png
skills/svgator-animate/SKILL.md
skills/svgator-animate/agents/openai.yaml
skills/svgator-setup/SKILL.md
skills/svgator-setup/agents/openai.yaml
```

The `.app.json` inside the ZIP contains only the installing user's ChatGPT App
reference; it contains **no OAuth tokens or login secrets**. Nonetheless,
personalized ZIPs and App IDs must never be published or shared.

## Local checks

On Linux and macOS using Nix:

```sh
nix develop
nix flake check
```

Without Nix, install Bash, jq, ShellCheck, zip and unzip, then run:

```sh
bash scripts/test-package.sh
```

Tests use only synthetic `asdk_app_Test123` identifiers. They verify
Bash/ShellCheck syntax, shared metadata consistency across both manifests,
the precise eight-file allowlist, normalization of the optional `plugin_`
App ID prefix, rejection of invalid identifiers, mismatched versioned ZIP
names, and refusal to overwrite existing packages.

The test does not contact SVGator or ChatGPT, and passing it does **not**
establish that authentication, animation playback, or exporting works.

## Making changes

1. Work on a feature branch. Preserve existing App and OAuth security rules.
2. Edit the source files in `skills/` rather than a generated ZIP.
3. For metadata or version changes, update **both** manifests.
4. Keep README and these documentation pages aligned with supported commands.
5. Run `bash scripts/test-package.sh` or `nix flake check`.
6. Open a pull request and review GitHub Actions checks before merging.
7. Test installation and a harmless authenticated SVGator read separately.

## Release procedure

1. Bump semantic version in both manifests and document behavior changes.
2. Confirm the CI checks pass on the proposed release commit.
3. Build a **neutral source-template archive** with the repository files,
   including `LICENSE` and `assets/README.md`. Do not include personalized
   `.app.json` or a private plugin ZIP.
4. Calculate and publish a SHA-256 checksum for that neutral archive.
5. Tell installers to regenerate their private ZIP with their existing App ID.

The CFMoon icon and demonstration GIF are excluded from Apache-2.0; see
[the artwork notice](../assets/README.md). The generated eight-file ZIP does
not include that notice by design, and must remain private.
