---
name: svgator-setup
description: "Connect and verify SVGator in Codex without changing projects. Use during onboarding, before the first animation, or when SVGator tools are missing, authorization is uncertain, or a connection fails."
---

# Connect and verify SVGator

This Codex plugin bundles one `svgator` MCP connection to
`https://mcp.svgator.com/mcp`. Use that packaged connection and let Codex manage
OAuth with Dynamic Client Registration. Do not create a second standalone
SVGator server as part of setup or verification.

## Check access safely

1. Discover the SVGator tools actually exposed to this conversation. Do not
   infer connectivity from a visible plugin, a successful package upload, or
   remembered tool names.
2. Use SVGator's `ping` diagnostic when it is available, then call the harmless
   authenticated `get_profile` read. Do not list projects unless the user asks.
3. Report one clear state: connected and authenticated; tools unavailable;
   authentication required; or a transport/server failure. Include account or
   plan details only when they help the user understand the result.

Never create, modify, duplicate, or export a project solely to verify the
connection.

## Handle a failed check

- If SVGator tools are absent, confirm that this plugin is installed and
  enabled, inspect the packaged connection through `/mcp` or
  `codex mcp list`, and retry in a fresh conversation. Do not create another
  plugin or MCP server as a test.
- If a tool returns an authentication or consent error, use Codex's connection
  prompt or log in to the exact packaged server name shown by `/mcp`. Never
  request an App ID, OAuth code, token, password, or cookie in chat.
- If the server returns one transient `502 Bad Gateway`, retry the same harmless
  read once. If it fails again, report the server as currently unavailable.
- Treat `invalid_client` as an OAuth client-registration problem. Reconnect the
  packaged server using Codex's supported OAuth flow; rebuilding the plugin or
  adding a duplicate server does not repair an existing registration.

Do not claim success until an authenticated read succeeds. Preserve the
relevant error message when it does not, while omitting credentials and
unnecessary personal data.
