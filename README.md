# CFMoon SVGator for ChatGPT — template

This template turns a custom SVGator App created in ChatGPT into a private
ChatGPT plugin with CFMoon's complete SVGator animation workflows.

It is an independent CFMoon integration. It is not an official SVGator plugin
and is not affiliated with or endorsed by SVGator.

## What this template is

The reusable parts are already included:

- CFMoon plugin metadata and icon.
- The `svgator-animate` and `svgator-setup` skills.
- A private-App dependency declaration in both plugin manifests.
- A local preparation script that creates `.app.json` from your ChatGPT App ID.

The template intentionally contains no `.app.json`, real App ID, OAuth token,
client secret, or `mcp.json`. It cannot be uploaded successfully until you
personalize it. The generated ZIP uses one connection path: your registered
ChatGPT App.

## Before you begin

You need:

- Permission to add a custom MCP server in your ChatGPT account or workspace.
- A custom App created from `https://mcp.svgator.com/mcp` through
  <https://chatgpt.com/plugins>.
- A completed SVGator authorization flow for that App.
- The App's technical ID from the ChatGPT interface. In the tested workspace
  interface it begins with `asdk_app_`. OpenAI's current documentation also
  describes a browser-URL form beginning with `plugin_asdk_app`; the preparation
  script accepts either form.
- `zip` installed locally. `unzip` is recommended for inspection. Nix users
  can run `nix develop` to enter a shell with all required tools.

Do not paste OAuth tokens, cookies, passwords, or client secrets into this
template. The only input used by the preparation script is the generated App
technical ID.

## Prepare your private ZIP

### 1. Download and extract the template

Download the ChatGPT template archive from the matching GitHub release and
extract it. Enter the extracted directory in a terminal.

The release archive is a template, not the final plugin ZIP.

### 2. Copy the ChatGPT App technical ID

Open the custom App you created in ChatGPT and copy its technical ID. In the
tested interface, use the full value beginning with `asdk_app_`.

Treat this value as workspace-specific configuration. It is not an OAuth token,
but do not publish your personalized package or commit the value to Git.

### 3. Run the preparation script

From the extracted template directory:

```sh
chmod +x ./scripts/prepare-chatgpt-plugin.sh
./scripts/prepare-chatgpt-plugin.sh \
  'asdk_app_REPLACE_WITH_YOUR_VALUE' \
  './export/'
```

The script uses an `asdk_app_...` value directly. For compatibility with the
form in OpenAI's current documentation, it also accepts `plugin_asdk_app_...`
and removes only the leading `plugin_` before writing `.app.json`. It validates
the format, copies only the plugin components, writes the binding without
printing it, creates the output directory when needed, and names the final ZIP
from the `name` and `version` in `plugin.json`. With the current manifest, the
command above creates
`./export/cfmoon-svgator-animations-chatgpt-0.3.2.zip`. Omitting the second
argument writes that versioned filename under `./dist/`.

You may instead pass a complete path such as
`./export/plugin-0.3.2.zip`. Its filename must include the current manifest
version; this prevents an archive built from version `0.3.2` from being labeled
as `0.3.1`. The script creates missing parent directories and refuses to
overwrite an existing archive.

### 4. Inspect the archive without exposing the binding

```sh
unzip -t ./export/cfmoon-svgator-animations-chatgpt-0.3.2.zip
unzip -l ./export/cfmoon-svgator-animations-chatgpt-0.3.2.zip
```

The archive should contain exactly these eight files:

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

It must not contain `mcp.json`, `.mcp.json`, this README, or the preparation
script. Avoid commands that print `.app.json` into terminal logs, screenshots,
or support tickets.

## Nix development environment

The repository includes a standalone flake for Linux and macOS:

```sh
nix develop
nix flake check
```

The development shell provides `bash`, `jq`, `shellcheck`, `zip`, and `unzip`.
The flake check validates the shell script and exercises a complete private-ZIP
build with a synthetic App ID. It never needs a real ChatGPT App binding.

## Import it into ChatGPT

Use the same private or workspace plugin-import flow that is available to your
account. When using Plugin Creator in ChatGPT Work:

1. Start a Plugin Creator conversation.
2. Attach the generated ZIP, not the downloaded template archive.
3. Ask: `Create a private workspace plugin from this archive. Keep its existing name, metadata, App dependency, and skills. Do not submit it publicly.`
4. Review the package diagnostics and confirm that it finds two skills and one
   App dependency.
5. Keep the plugin private during testing.

Do not use the public Plugin Directory submission portal for this ZIP. Public
submission rejects packages containing `apps` or `.app.json` references.

The labels in ChatGPT can vary by account and workspace permissions. If your
workspace presents an existing private ZIP-import control instead of Plugin
Creator, use that control and record its exact label in the test notes below.

## Test the installed plugin

1. Install or enable **CFMoon SVGator for ChatGPT**.
2. Start a new ChatGPT Work conversation.
3. Invoke the plugin explicitly.
4. Ask: `Verify my SVGator connection without creating, editing, or exporting any projects.`
5. Confirm that ChatGPT uses the registered SVGator App, performs a harmless
   authenticated read, and reports whether the connection is ready.
6. If the first harmless request returns one transient `502 Bad Gateway`, retry
   it once before treating the server as unavailable.
7. Do not create, edit, or export a project solely to test authentication.

The plugin appearing in the directory proves only that the package installed.
The harmless authenticated read verifies that the App dependency and current
SVGator authorization are usable together.

## Troubleshooting

- **The script rejects the ID:** copy the technical ID shown by ChatGPT. In the
  tested workspace it begins with `asdk_app_`. Do not paste the whole URL.
- **The ZIP is rejected immediately:** confirm you uploaded the generated ZIP,
  not the template download, and that `.app.json` exists at its root.
- **The plugin installs but SVGator is unauthorized:** reconnect the original
  custom SVGator App in ChatGPT. Rebuilding the ZIP does not repair OAuth state.
- **Both the basic custom App and the CFMoon plugin appear:** do not delete the
  registered App while the CFMoon plugin depends on it. Invoke the CFMoon plugin
  for workflow testing and record whether ChatGPT exposes redundant entries.
- **A public-submission error mentions app configuration:** this is expected in
  the public portal. This package is private/workspace-only.

## Tester notes

Record these results before we simplify the flow:

- Time required to find and copy the App technical ID.
- Whether the browser ID was obvious or confusing.
- Time required to run the script and locate the generated ZIP.
- Exact ChatGPT menu and button labels used to import it.
- Whether both the basic App and enriched plugin appeared.
- Number and wording of authorization prompts.
- Result of the connection-verification request.
- Any step that required knowledge not present in this guide.

## Updating later

Treat the extracted template as source and every generated private ZIP as a
disposable build artifact. Update files in the template, then create a complete
new ZIP; do not edit an old generated ZIP in place.

Changes to bundled skills, plugin metadata, or the icon require a new package
version. Changes made by SVGator to its hosted MCP server are separate from
this package: rebuilding the ZIP does not update, reconnect, or repair the
registered ChatGPT App or its SVGator authorization.

### Update to a later CFMoon release

1. Keep the existing custom SVGator App registered in ChatGPT. Do not delete it
   while the private plugin depends on it.
2. Copy the same App technical ID used for the previous build from ChatGPT. It
   should begin with `asdk_app_` in the tested interface. This is an App
   reference, not an OAuth code, access token, or client secret.
3. Download and extract the new CFMoon template into a new directory. Do not
   copy `.app.json` or other generated files out of the previous ZIP.
4. Check the new version in `plugin.json` and confirm that
   `.codex-plugin/plugin.json` has the same version.
5. Run the preparation script again with the existing App technical ID. Pass
   an output directory and let the script derive the filename from the new
   manifest version:

   ```sh
   ./scripts/prepare-chatgpt-plugin.sh \
     'asdk_app_REPLACE_WITH_YOUR_EXISTING_VALUE' \
     './export/'
   ```

6. Inspect the new archive as described in **Prepare your private ZIP**. It
   must be a complete eight-file package, not a partial skills-only update.
7. Open the existing private plugin in ChatGPT and use the update, edit, or
   replace-package control available to your account. Upload the new generated
   ZIP to that existing plugin rather than creating a second plugin.
8. Confirm that ChatGPT reports the expected new version, two skills, and the
   existing SVGator App dependency. Keep the plugin private.
9. Start a new conversation and repeat the connection-verification test from
   **Test the installed plugin**.

The user must enter the App technical ID again for every rebuild. This is
intentional: the reusable template never stores a workspace-specific ID, and
the preparation script creates `.app.json` only inside the generated private
ZIP. Reusing the same ID preserves the same registered App binding. A new App
ID is needed only when the original custom App was deliberately replaced.

ChatGPT labels vary by account and workspace. If no update control is visible,
do not import the ZIP as a new plugin merely to continue. Record the available
controls and ask the workspace administrator or Plugin Creator how to update
the existing private plugin without changing its identity.

### Maintain or customize the template

Make changes in the extracted repository source before rebuilding:

- Edit `skills/svgator-animate/SKILL.md` or
  `skills/svgator-setup/SKILL.md` to change workflow instructions.
- Edit the corresponding `agents/openai.yaml` file when skill presentation or
  invocation metadata changes.
- Edit `plugin.json` for portable identity and presentation metadata, then keep
  every repeated field synchronized in `.codex-plugin/plugin.json`.
- Replace the icon only with artwork you are authorized to use. The bundled
  CFMoon illustration may not be modified under its asset notice.
- Keep the stable plugin `name` unchanged when updating an existing plugin.

For every template release:

1. Choose a new semantic version and set it in both manifests.
2. Run `nix flake check` from the template directory.
3. Run the preparation script with a synthetic App ID and inspect the resulting
   eight paths before distributing the neutral template.
4. Record release notes describing the changed skills, metadata, or assets.
5. Ask each installer to rebuild their own private ZIP with their existing App
   technical ID. Never request that they send the ID to CFMoon.

OpenAI's documented package-update model likewise requires a new complete ZIP
and version for changes to bundled skills, metadata, or assets. Its public
submission controls differ from this private App-reference flow, so follow the
private update controls actually shown in the installer's ChatGPT workspace.

## References

- [OpenAI: create and test a plugin with a custom MCP server](https://developers.openai.com/plugins/build/plugins#create-and-test-a-plugin-locally-with-an-mcp-server)
- [OpenAI: plugin package structure](https://developers.openai.com/plugins/build/plugins)
- [OpenAI: update an existing plugin package](https://developers.openai.com/plugins/deploy/submission#update-your-published-plugin)
- [OpenAI: public ZIP restrictions](https://developers.openai.com/plugins/deploy/submission-errors#zip-upload-errors-and-warnings)

## License

Except for the artwork and branding identified below, this repository's code,
documentation, configuration, and skills are licensed under the
[Apache License 2.0](./LICENSE).

`assets/cfmoon-svgator-animations.png` and the CFMoon names and branding are
excluded from that license. The image is Copyright 2026 CFMoon and may be
redistributed unchanged only as part of this template or a private plugin
archive generated from it. See the [asset notice](./assets/README.md) for the
complete terms. No trademark rights are granted.

The `Apache-2.0` value in the plugin manifests describes the reusable plugin
implementation; it does not license the excluded artwork or any trademark. To
preserve the current eight-file ChatGPT upload contract, generated private ZIPs
do not contain the repository's license or asset-notice files.
