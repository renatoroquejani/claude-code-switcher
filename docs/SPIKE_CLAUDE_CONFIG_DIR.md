# Spike: `CLAUDE_CONFIG_DIR`

This document records the current investigation into isolated Claude Code instances for multi-account support.

## Objective

Validate whether Claude Code can be safely isolated per account by launching it with different `CLAUDE_CONFIG_DIR` values, instead of mutating one shared `~/.claude/settings.json`.

This is the preferred architecture for multi-account Claude Pro support because it avoids direct token juggling and keeps account state separated by directory.

## Status

Validated manually in the user's real shell.

The Codex runtime could not execute the user's real Claude binary due runtime confinement, but the manual checklist was completed successfully in the user's normal shell session.

## What Was Verified

The following facts were confirmed from the host filesystem:

- Claude is installed at `/home/renato/.local/bin/claude`
- the installed entrypoint is a symlink to `/home/renato/.local/share/claude/versions/2.1.74`
- the user's Claude directory exists at `/home/renato/.claude`

The following constraints were also confirmed:

- the sandbox `HOME` points to the Snap runtime home, not `/home/renato`
- `/home/renato/.local` is mode `700`, which prevents this execution context from traversing and executing the real Claude binary
- attempts to execute `/home/renato/.local/bin/claude` or inspect `/home/renato/.claude` from this environment failed with `Permission denied`
- the same failure persisted even after switching the agent to `danger-full-access`, which indicates the remaining blocker is runtime confinement around the Codex/Snap process rather than the task policy itself

The following facts were then confirmed manually by the user in a normal shell:

- `claude --version` works with `CLAUDE_CONFIG_DIR` pointed at a temp directory
- opening Claude with two different `CLAUDE_CONFIG_DIR` values produced two different state trees
- the two isolated directories could be logged into with different accounts
- re-running Claude with literal temp paths in separate terminals worked correctly
- instance state included separate `.claude.json`, `backups/`, `cache/`, and `plugins/`

## Conclusion

The preferred architecture remains:

- one switcher-managed state root
- one isolated Claude instance directory per account
- provider switching applied to the active instance
- Claude launched with account-specific environment

The key architectural claim is now verified:

- `CLAUDE_CONFIG_DIR` is sufficient to isolate Claude Code account state on the installed Claude Code version used in this project

This makes per-account instance directories the correct default architecture for multi-account support.

## Sources

Official Anthropic documentation confirms project and global configuration patterns, but it does not confirm `CLAUDE_CONFIG_DIR`:

- https://docs.anthropic.com/en/docs/claude-code/quickstart
- https://docs.anthropic.com/es/docs/claude-code/settings

The `CLAUDE_CONFIG_DIR` approach is documented by `ccs` and is the main inspiration for the architecture:

- https://docs.ccs.kaitran.ca/providers/claude-accounts
- https://docs.ccs.kaitran.ca/providers/concepts/overview

## Manual Validation Checklist

Run these checks from the real user shell where `claude --version` succeeds.

### Check 1: basic isolated startup

```bash
dir_a=$(mktemp -d)
dir_b=$(mktemp -d)

CLAUDE_CONFIG_DIR="$dir_a" claude --version
CLAUDE_CONFIG_DIR="$dir_b" claude --version

find "$dir_a" -maxdepth 3 -type f | sort
find "$dir_b" -maxdepth 3 -type f | sort
```

Expected:

- Claude runs successfully in both directories
- per-instance files are created under each directory
- no files are written into the other directory as a side effect

### Check 2: isolated login state

```bash
dir_a=$(mktemp -d)
dir_b=$(mktemp -d)

CLAUDE_CONFIG_DIR="$dir_a" claude
CLAUDE_CONFIG_DIR="$dir_b" claude
```

Expected:

- account A login does not authenticate account B automatically
- both directories retain different session state after login

### Check 3: provider isolation

After login, point `claude-switch` at a copied settings file inside one isolated directory and verify only that directory changes.

Expected:

- account A provider switch does not alter account B settings

### Check 4: parallel terminals

Open two terminals and launch Claude from different instance directories.

Expected:

- both sessions run at the same time
- account identity and provider selection remain isolated

## Fallback Plan

If `CLAUDE_CONFIG_DIR` is incomplete or unreliable, use directory snapshots:

- keep a full per-account Claude state copy
- copy or sync the selected account into the active runtime directory before launch

This is less elegant, but still supports multi-account switching.
