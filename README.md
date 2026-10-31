# CFMoon SVGator Plugin for ChatGPT and Codex

**Create, audit, edit, and export SVGator animations from ChatGPT or Codex, using reusable CFMoon workflows.**


![SIGNAL STRIKE example animation](assets/signal-strike-demo.gif)

This community plugin combines [SVGator's official MCP server](https://github.com/SVGator/mcp) with three CFMoon skills: one for animation authoring, one for read-only project audits, and one for connection verification. It lets you work conversationally in ChatGPT and then open the same project in SVGator's browser editor for finishing touches.

> **Independent integration.** Built by CFMoon Software. Not an official SVGator plugin and not affiliated with or endorsed by SVGator.

## What can it do?

- Create and refine animated logos, brand reveals, loaders, motion graphics, and reusable templates.
- Audit existing projects for editable text, replaceable assets, and template readiness without modifying them.
- Change text, artwork, colors, timing, and motion through natural-language instructions.
- Use structured workflows to preserve unrelated layers and keep replacements editable.
- Export supported formats through SVGator, subject to your SVGator plan.
- Open projects in SVGator's web editor when you want hands-on control.

**Try asking:**

> Create a 4-second geometric lightning logo reveal. Keep the logo and headline replaceable, then give me the SVGator project link.

> Duplicate this animation and swap the logo, headline, product image, and brand colors without changing its timing.

> Audit this project for editable text, replaceable assets, and animation structure. Do not modify or export anything.

### What powers it?

```text
ChatGPT or Codex
  └─ CFMoon workflows
       ├─ svgator-animate skill
       ├─ svgator-audit skill (read-only)
       ├─ svgator-setup skill
       └─ Host-specific connection
            ├─ ChatGPT: registered App → SVGator MCP (OAuth)
            └─ Codex: packaged connection → SVGator MCP (OAuth/DCR)
                 └─ Your SVGator projects
```

The plugin **does not host, replace, or redistribute** SVGator's MCP server. It adds repeatable workflows around the server you authorize in your own account.

## Use with Codex

Register this repository as a marketplace, then install its Codex target:

```sh
codex plugin marketplace add cfmoon-software/SVGator-ChatGPT-Plugin
codex plugin add cfmoon-svgator-animations@cfmoon-software
```

See the [complete Codex installation and maintenance guide](codex/README.md)
for requirements, checkout-based installation, SVGator authorization, updates,
uninstallation, and troubleshooting.

## Use with ChatGPT

You'll need a **SVGator account**, access to **custom MCP connections in ChatGPT**, permission to install or import a **private plugin**, and a terminal with **Bash**, **jq**, and **zip**. ChatGPT menus and installation permissions vary by account and workspace.

### 1. Connect SVGator to ChatGPT

1. Open [ChatGPT Plugins](https://chatgpt.com/plugins).
2. Select **Add (+) → Add custom MCP server** (or the equivalent control in your workspace).
3. Enter the official SVGator MCP URL:

   ```text
   https://mcp.svgator.com/mcp
   ```

4. Finish the connection and authorize it with your **own SVGator account** using the offered OAuth sign-in flow.
5. Check that the newly registered connection appears in your Plugins area.

If you can't see **Add custom MCP server**, check your account/workspace permissions and the [current OpenAI setup guide](https://developers.openai.com/plugins/deploy/connect-chatgpt). Don't assume that switching on Developer Mode is required for every account.

### 2. Find your ChatGPT App ID

Open the newly created SVGator connection's details. Copy its **technical App ID**, not the SVGator URL or an OAuth credential.

Depending on the interface, it may look like `asdk_app_...` or `plugin_asdk_app_...`. The preparation script accepts either form and normalizes the value for the package.

This ID is a reference to **your registered ChatGPT App**. It is not an OAuth access token, but the ZIP generated from it is personalized and should remain private.

### 3. Build your private plugin ZIP

Clone this repository or download and extract its source archive, then run from the repository root:

```bash
chmod +x ./scripts/prepare-chatgpt-plugin.sh
./scripts/prepare-chatgpt-plugin.sh \
  'asdk_app_REPLACE_WITH_YOUR_VALUE' \
  './export/'
```

Replace the example with your real App ID. If the script succeeds, it creates a **versioned private ZIP** in `./export/` (for this release, `cfmoon-svgator-animations-chatgpt-0.4.0.zip`).

A ZIP downloaded directly from GitHub is the reusable source template, not the
personalized plugin to import. The preparation script builds the importable
archive locally.

### 4. Install the generated ZIP in ChatGPT

Use whichever **private plugin import** method your account supports:

- **Plugin Creator:** Start a conversation with `@plugin-creator`, attach your newly generated ZIP, and ask it to create a **private** plugin while preserving the packaged skills, metadata, and existing registered App dependency.
- **Private ZIP upload:** If your account/workspace exposes **Upload plugin**, upload the generated ZIP rather than the source archive.

Review the result. It should contain **three skills** and **one App dependency**. An ordinary custom SVGator connection and the CFMoon workflow plugin may both appear; keep the underlying App because the CFMoon package references it.

If your account doesn't offer either installation route, don't try to turn this private package into a public directory submission. See the [official plugin documentation](https://help.openai.com/en/articles/20001256-plugins-in-chatgpt) for available installation options.

### 5. Verify the connection

Start a **new conversation** with the installed CFMoon plugin selected and ask:

> Verify my SVGator connection without creating, editing, or exporting any projects.

The setup workflow performs a harmless connectivity check and an authenticated account read. A plugin appearing in your directory is **not**, by itself, proof that the SVGator connection is authorized.

**You're ready.** Try one of the prompts above, or ask for an editor link to a project you already own.

## Read-only project audits

Ask the `svgator-audit` skill to inspect an existing project without modifying, duplicating, rendering, or exporting it. The report separates **verified facts** (element types, names, animator channels, project settings), **potential issues**, and **unverified aspects** (visual playback, font portability, commercial rights, and whether another brand truly works). The audit is an evidence-backed inspection, not an automatic quality certification.

## Built with ChatGPT, tested with SIGNAL STRIKE

The first working version of this integration was built entirely within ChatGPT using **Plugin Builder**. Much of the creative work happened from a phone; the repository, Git workflow, and distributable packaging came later on a laptop.

We used the integration to create and refine **SIGNAL STRIKE**, a reusable cyber-lightning animation with different brand identities sharing the same motion. It was created for the SVGator × Contra challenge and serves as a real-world demonstration of the workflow.

## Documentation

- [Codex installation and maintenance](codex/README.md) — marketplace and checkout installation, authorization, updates, and troubleshooting.
- [Development and package structure](docs/development.md) — source files, build contract, Nix, and release checks.
- [Troubleshooting](docs/troubleshooting.md) — connection failures, import issues, and authentication.
- [Updating](docs/updating.md) — rebuilding and upgrading a private installation without losing the existing App binding.

## Security and privacy

- Never share OAuth tokens, passwords, cookies, client secrets, `.app.json`, or
  personalized plugin ZIPs.
- The repository contains no account credentials. SVGator authentication is
  handled by each host through the connection the user authorizes.

## License

The repository's code, configuration, documentation, and skills are licensed under **Apache License 2.0**, except for the artwork and branding excluded below.

`assets/cfmoon-svgator-animations.png`, the CFMoon name, and CFMoon branding are **not** covered by Apache-2.0. The included illustration may be redistributed **unchanged** only with this template or a generated private plugin archive, subject to its repository asset notice. No trademark rights are granted.

The package manifest's Apache-2.0 field describes the reusable plugin implementation, **not** the excluded artwork. Generated private ZIPs intentionally contain the required plugin files rather than the entire source repository. The SIGNAL STRIKE demo GIF is also excluded from Apache-2.0; see [the asset notice](assets/README.md).
