# CFMoon SVGator Animations for Codex

Install and maintain the Codex target from the CFMoon SVGator monorepo. For the
project overview, capabilities, ChatGPT setup, and licensing, see the
[main README](../README.md).

> **Independent integration.** Developed and maintained by CFMoon Software.
> This is not an official SVGator plugin and is not affiliated with or endorsed
> by SVGator.

This directory is the self-contained Codex plugin target. It packages the three
SVGator workflows and one OAuth/DCR connection to SVGator's hosted MCP server.

## Requirements

- A current Codex client with plugin marketplace support.
- A SVGator account.
- Access to GitHub for the recommended marketplace installation, or a local
  checkout of this repository.

## Install from the marketplace (recommended)

Add the repository as a Git marketplace, then install the plugin exposed by its
`cfmoon-svgator` marketplace:

```sh
codex plugin marketplace add cfmoon-software/SVGator-ChatGPT-Plugin
codex plugin add cfmoon-svgator-animations@cfmoon-svgator
```

Confirm the installation:

```sh
codex plugin list --json
```

Look for `cfmoon-svgator-animations@cfmoon-svgator` in the installed plugins.

## Install from a checkout

Every checkout contains the same marketplace catalog. From the repository root,
register that directory instead of the GitHub source:

```sh
git clone https://github.com/cfmoon-software/SVGator-ChatGPT-Plugin.git
cd SVGator-ChatGPT-Plugin
codex plugin marketplace add .
codex plugin add cfmoon-svgator-animations@cfmoon-svgator
```

This is useful for contributors, local testing, or installing a checked-out
branch. Codex resolves the marketplace's `./codex` source path relative to the
repository root.

## Connect SVGator and verify access

After installation:

1. Complete the SVGator OAuth flow when Codex prompts you.
2. Start a fresh conversation. In Codex CLI, use `/new` if needed.
3. Ask:

   > Verify my SVGator connection without creating, editing, or exporting any projects.

The setup workflow performs a harmless connectivity check followed by an
authenticated profile read. It does not create, edit, duplicate, or export a
project.

If authorization did not open automatically, inspect the packaged connection
with `/mcp` and reconnect the exact SVGator server shown there. Never paste an
OAuth code, token, password, cookie, or client secret into chat.

## Avoid duplicate connections

Do not also run:

```sh
codex mcp add svgator --url https://mcp.svgator.com/mcp
```

The plugin already provides that connection. A standalone declaration can
produce duplicate tools and authentication prompts.

If you installed an older `cfmoon-svgator-animations` package from another
marketplace, list your current installations and remove the older one before
enabling this package:

```sh
codex plugin list --json
codex plugin remove cfmoon-svgator-animations@OLD_MARKETPLACE_NAME
```

Replace `OLD_MARKETPLACE_NAME` with the marketplace shown by the list command.
Removing a plugin does not delete projects stored in your SVGator account.

## Update

For the recommended Git marketplace installation, refresh the marketplace:

```sh
codex plugin marketplace upgrade cfmoon-svgator
```

Then start a new conversation so Codex loads the refreshed skills and tools.
Use `codex plugin list --json` to confirm the installed version.

For a local checkout, pull the desired revision, then remove and reinstall the
local plugin so its cached copy is refreshed:

```sh
git pull --ff-only
codex plugin remove cfmoon-svgator-animations@cfmoon-svgator
codex plugin add cfmoon-svgator-animations@cfmoon-svgator
```

## Uninstall

Remove the plugin first, then optionally remove the marketplace source:

```sh
codex plugin remove cfmoon-svgator-animations@cfmoon-svgator
codex plugin marketplace remove cfmoon-svgator
```

This removes Codex's installed plugin files and marketplace registration. It
does not delete SVGator projects.

## Troubleshooting

- **Plugin is not listed:** run `codex plugin marketplace list`, refresh the
  marketplace, and retry `codex plugin add`.
- **Tools are absent in an existing conversation:** start a new conversation
  after installing or updating.
- **Authentication is required:** inspect `/mcp` and reconnect the packaged
  SVGator server.
- **Duplicate SVGator tools appear:** remove the older plugin or standalone MCP
  declaration, then start a new conversation.
- **One `502 Bad Gateway` occurs:** retry the same harmless connection check
  once before treating SVGator's server as unavailable.

Package validation proves the manifests and bundled files are structurally
correct; connection verification proves whether the current SVGator account is
authorized.

## References

- [OpenAI: add a plugin marketplace](https://developers.openai.com/plugins/build/plugins#add-a-marketplace-from-the-cli)
- [OpenAI: install a local plugin](https://developers.openai.com/plugins/build/plugins#install-a-local-plugin-manually)
- [SVGator MCP server](https://github.com/SVGator/mcp)
