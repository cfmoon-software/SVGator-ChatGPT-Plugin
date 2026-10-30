# Codex plugin target

This directory is the self-contained Codex distribution of CFMoon SVGator
Animations. It connects directly to SVGator's hosted MCP server through OAuth
with Dynamic Client Registration. It does not use or contain a ChatGPT App ID.

From a checkout of this repository, register the local marketplace and install
the plugin:

```sh
codex plugin marketplace add .
codex plugin add cfmoon-svgator-animations@cfmoon-svgator
```

For a GitHub-hosted checkout, replace `.` with the repository's `owner/repo`
name. Restart Codex or start a fresh conversation after installation, complete
the SVGator OAuth flow when prompted, and run the suggested connection check.

Do not also add `https://mcp.svgator.com/mcp` as a standalone Codex MCP server.
The plugin already provides that connection, and a second declaration can cause
duplicate tools and authentication prompts. Disable or remove an older
`cfmoon-svgator-animations` installation from another marketplace before
enabling this package.
