# Development and package structure

This repository contains two host-specific targets built around the same three
SVGator workflows:

- The repository root is the neutral ChatGPT source template. Each ChatGPT
  installer registers their own SVGator App and generates a personalized ZIP.
- `codex/` is an installable Codex plugin. It declares SVGator's hosted MCP
  endpoint and lets each user complete OAuth/DCR through Codex.

Never commit or distribute a personalized ChatGPT ZIP.

## Source layout

| Path | Purpose |
| --- | --- |
| `plugin.json` | Root plugin metadata and OpenAI App reference declaration |
| `.codex-plugin/plugin.json` | Compatibility metadata for plugin import |
| `skills/svgator-animate/` | SVGator animation authoring and editing guidance |
| `skills/svgator-audit/` | Read-only project and template inspections |
| `skills/svgator-setup/` | Read-only SVGator authentication verification |
| `assets/cfmoon-svgator-animations.png` | Proprietary CFMoon plugin icon |
| `assets/signal-strike-demo.gif` | README demonstration, not packaged in the private ZIP |
| `scripts/prepare-chatgpt-plugin.sh` | Generates the personalized private ZIP |
| `scripts/test-package.sh` | Portable manifest, safety and build contract tests |
| `flake.nix` | Nix developer shell and the same reproducible test suite |
| `.github/workflows/validate.yml` | CI for pull requests and changes to `main` |
| `codex/` | Self-contained Codex plugin with direct SVGator OAuth/DCR MCP configuration |
| `.agents/plugins/marketplace.json` | Repository marketplace entry for Codex installation |
| `scripts/test-codex-package.sh` | Codex manifests, marketplace, MCP and file-contract checks |

The build script always packages these **ten files**, and no others:

```text
plugin.json
.app.json
.codex-plugin/plugin.json
assets/cfmoon-svgator-animations.png
skills/svgator-animate/SKILL.md
skills/svgator-animate/agents/openai.yaml
skills/svgator-audit/SKILL.md
skills/svgator-audit/agents/openai.yaml
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
the precise ten-file allowlist, normalization of the optional `plugin_`
App ID prefix, rejection of invalid identifiers, mismatched versioned ZIP
names, and refusal to overwrite existing packages. The same suite also checks
the Codex target's eleven-file allowlist, direct OAuth/DCR MCP declaration,
marketplace entry, manifest synchronization, absence of ChatGPT App IDs, and
shared icon and workflow files.

The test does not contact SVGator, ChatGPT, or Codex, and passing it does **not**
establish that authentication, animation playback, or exporting works.

## Test the Codex target locally

Run the full portable suite first, then register the checkout as a temporary
local marketplace using your normal Codex profile:

```sh
bash scripts/test-package.sh
codex plugin marketplace add .
codex plugin add cfmoon-svgator-animations@cfmoon-svgator
```

Start a fresh conversation, complete the SVGator OAuth flow, and run the
read-only connection verification. Local package checks do not replace that
host test. Avoid adding a separate standalone SVGator MCP server alongside the
plugin, and disable any older installation from another marketplace before
testing this target.

## Making changes

1. Work on a feature branch. Preserve existing App and OAuth security rules.
2. Edit the ChatGPT source files in `skills/` rather than a generated ZIP.
   Keep the portable animation and audit workflows synchronized with their
   copies under `codex/skills/`; the two setup skills intentionally differ by
   host.
3. For ChatGPT metadata or version changes, update both root manifests. For
   Codex metadata changes, update both manifests under `codex/`. Keep target
   versions aligned for a shared release.
4. Keep README and these documentation pages aligned with supported commands.
5. Run `bash scripts/test-package.sh` or `nix flake check`.
6. Open a pull request and review GitHub Actions checks before merging.
7. Test ChatGPT and Codex installation and a harmless authenticated SVGator
   read separately.

## Release procedure

1. Bump semantic version in both manifests and document behavior changes.
2. Confirm the CI checks pass on the proposed release commit.
3. Build a **neutral monorepo source archive** with the repository files,
   including `LICENSE` and `assets/README.md`. Do not include personalized
   `.app.json` or a private plugin ZIP.
4. Calculate and publish a SHA-256 checksum for that neutral archive.
5. Tell installers to regenerate their private ZIP with their existing App ID.

The CFMoon icon and demonstration GIF are excluded from Apache-2.0; see
[the artwork notice](../assets/README.md). The generated ten-file ZIP does
not include that notice by design, and must remain private.
