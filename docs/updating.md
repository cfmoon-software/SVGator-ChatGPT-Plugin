# Updating an existing private installation

Keep your original **custom SVGator ChatGPT App** registered. The CFMoon plugin
uses the App's technical ID to reference that connection, so an ordinary plugin
update should **not** require creating another App or repeating SVGator OAuth.

## Upgrade steps

1. Download the new CFMoon **source template** release into a fresh directory.
   Do not carry forward a generated `.app.json` or private ZIP.
2. Read the package version in `plugin.json` and verify
   `.codex-plugin/plugin.json` matches it.
3. Retrieve the **same existing ChatGPT App technical ID** from ChatGPT. It
   commonly begins with `asdk_app_`; the builder also accepts the documented
   `plugin_asdk_app_` form.
4. From the newly extracted template, run:

   ```bash
   ./scripts/prepare-chatgpt-plugin.sh \
     'asdk_app_REPLACE_WITH_YOUR_EXISTING_VALUE' \
     './export/'
   ```

5. Inspect the archive paths without displaying its `.app.json` contents:

   ```sh
   unzip -t ./export/cfmoon-svgator-animations-chatgpt-0.3.3.zip
   unzip -l ./export/cfmoon-svgator-animations-chatgpt-0.3.3.zip
   ```

   Replace the example filename with the current manifest-derived version.

6. In ChatGPT, update or replace the **existing private plugin's package** if
   your account offers that control. Upload the newly generated ZIP, not the
   source template. Preserve its existing App dependency and keep it private.
7. Start a new conversation and ask for the harmless SVGator connection check.
   Only then test any updated animation authoring features.

## If the update control is absent

ChatGPT's private plugin administration controls vary across accounts and
workspaces. Do not create a second private plugin simply to bypass a missing
update action. Check the controls available in your workspace and consult
Plugin Creator or your workspace administrator.

## If you replaced the original SVGator App

A deliberately replaced App has a different technical ID. Rebuild the private
plugin against that new ID. Changing a package version alone will not fix a
missing or unauthorized MCP connection.

## Security and release boundaries

- Only locally generated private ZIPs contain the App reference.
- Never send CFMoon your ID, `.app.json`, OAuth tokens, or private ZIP.
- Do not upload a private ZIP to a GitHub issue, release, or public repository.
- Upstream SVGator MCP server updates are separate from CFMoon plugin releases.
