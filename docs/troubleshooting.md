# Troubleshooting

The CFMoon plugin references a **separately registered SVGator App** inside
ChatGPT. Installing the ZIP alone does not establish a working SVGator login.

## Connection and authorization

**The SVGator tools are missing.** Check that both your original custom SVGator
App and the CFMoon plugin are enabled in the current conversation. Start a new
chat if needed. Don't register a duplicate App merely to test connectivity.

**The plugin is installed but SVGator says unauthorized.** Reconnect the
existing SVGator App through ChatGPT's connection controls and complete the
official OAuth sign-in. Rebuilding the ZIP does not repair OAuth.

**An `invalid_client` error appears.** Check the existing ChatGPT App
registration. If you deliberately replace that App, build a new private ZIP
using the replacement App's technical ID.

**A request returns `502 Bad Gateway`.** Retry one harmless diagnostic once.
If it fails again, report the transport error; do not create or export test
projects as an authentication check.

**The SVGator connection appears twice.** This may be expected: one entry is
the original registered App, and the other is the CFMoon workflow plugin that
depends on it. Do not delete the underlying App while the plugin references it.

For safe verification, ask ChatGPT:

> Verify my SVGator connection without creating, editing, or exporting projects.

The plugin's setup skill should use `ping` where available and then a harmless
authenticated `get_profile` read.

## Packaging and installation

**The script rejects the App ID.** Copy the technical App ID from the
registered ChatGPT connection. Accepted forms begin with `asdk_app_` or
`plugin_asdk_app_`. Do not use a server URL, access token, or browser URL.

**The script says `jq` or `zip` is missing.** Install the missing command,
or enter the repository's Nix development environment with `nix develop`.

**The generated ZIP cannot overwrite an earlier build.** This is intentional.
Use a separate output directory or remove the earlier disposable build artifact
locally before rerunning the builder. Never overwrite a published release file.

**ChatGPT rejects the ZIP.** Upload the ZIP produced by the preparation script,
not GitHub's source-code download or a neutral release archive. Its root must
contain `plugin.json`, `.app.json`, the compatible manifest, the icon,
and the two skills with their `agents/openai.yaml` files (eight paths total).

**Plugin import or update controls are missing.** Private plugin import depends
on the capabilities and permissions of your ChatGPT account or workspace.
Consult current OpenAI plugin documentation; do not submit a personalized
package for public directory review.

**An export is not available.** Check SVGator plan permissions and the server's
current export capabilities. A successful project save is not proof that
an asynchronous render completed.

## Reporting problems safely

Include the package version, command or tool name, redacted error message,
and the exact visible UI label that failed. Never post OAuth credentials,
cookies, secrets, personalized ZIPs, `.app.json`, or your technical App ID
in issues, screenshots, or logs.
