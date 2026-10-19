---
name: svgator-setup
description: "Verify an existing SVGator connection without changing projects. Use during onboarding, before the first animation, or when SVGator tools are missing, authorization is uncertain, or a connection fails."
---

# Verify the SVGator connection

This private plugin is expected to contain a reference to an App that the user
already registered and authorized in ChatGPT. During normal onboarding, verify
that connection; do not repeat App registration or MCP setup.

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

- If SVGator tools are absent in ChatGPT, ask the user to confirm that this
  plugin is installed and enabled, then retry in a new conversation. Do not
  create another plugin or MCP server as a test.
- If a tool returns an authentication or consent error, direct the user to
  reconnect the existing custom SVGator App through ChatGPT's connection
  controls. Never request an App ID, OAuth code, token, password, or cookie in
  chat.
- If the server returns one transient `502 Bad Gateway`, retry the same harmless
  read once. If it fails again, report the server as currently unavailable.
- Treat `invalid_client` as a problem with the existing App registration. A
  package rebuild does not repair it. If the user deliberately replaces that
  App and receives a new App ID, they must rebuild the private plugin with the
  new ID.
- In local Codex, inspect the already configured connection through `/mcp` or
  `codex mcp list`. Log in to the exact existing server name only when needed;
  do not add a duplicate server as a verification step.

Do not claim success until an authenticated read succeeds. Preserve the
relevant error message when it does not, while omitting credentials and
unnecessary personal data.
