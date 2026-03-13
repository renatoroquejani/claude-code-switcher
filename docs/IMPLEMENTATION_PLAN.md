# Claude Code Switcher Implementation Plan

This document turns the current roadmap into an executable backlog with phased delivery, issue-sized work items, acceptance criteria, and file-level checklists.

## Goal

Evolve Claude Code Switcher from a single-instance provider switcher into a multi-account, multi-scope CLI while preserving its current strengths:

- pure Bash
- low-friction install
- explicit provider switching
- safe local file mutations

The highest-value addition is full multi-account Claude Pro support, so users can rotate between isolated Claude Code instances backed by separate paid accounts.

## Product Direction

### In Scope

- multiple isolated Claude Code accounts
- account-aware provider switching
- account-aware Claude launcher
- global and project configuration scopes
- diagnostics (`doctor`)
- versioned provider presets (`update-config`)
- named profiles
- declarative custom providers

### Out of Scope for Now

- web dashboard
- proxy server
- quota tracking and automated failover
- telemetry
- remote orchestration

## Delivery Strategy

Implement the work in this order:

1. `Spike 0`: verify account isolation mechanics
2. account state and isolated instances
3. account login and import flows
4. account-aware Claude launcher
5. project/global scope support
6. `doctor`
7. `update-config`
8. profiles and custom providers

This sequence reduces rework. Multi-account changes the storage model, so it has to land before project scope, diagnostics, or profiles.

## Proposed State Layout

```text
~/.claude-switcher/
├── state.json
├── accounts.json
├── profiles.json
├── providers.json
└── instances/
    ├── personal/
    │   ├── settings.json
    │   ├── backups/
    │   └── ...
    └── work/
        ├── settings.json
        ├── backups/
        └── ...
```

Design rule:

- never assume `~/.claude/settings.json` is the only writable target
- always resolve a target instance first, then resolve config scope inside that instance

## Release Boundaries

### v2.3.0

- Spike 0 completed
- account storage foundation
- account CRUD
- isolated provider switching

### v2.4.0

- account login/import/test
- `exec`
- optional shell alias integration

### v2.5.0

- project/global scope
- `doctor`

### v2.6.0

- `update-config`
- profiles
- custom providers

## Backlog

### Phase 0: Spike 0 - Validate Isolated Claude Configs

#### Issue 0.1 - Verify `CLAUDE_CONFIG_DIR` viability

Goal:

- confirm whether Claude Code can run with isolated config directories per account

Tasks:

- run Claude Code with `CLAUDE_CONFIG_DIR` pointed at a temp directory
- inspect which files are created and mutated
- verify authentication state remains isolated per directory
- verify provider switching works on a non-default settings path
- verify two terminals can run different active accounts concurrently

Acceptance Criteria:

- isolated directories can coexist without overwriting each other
- logging into account A does not authenticate account B
- switching providers in account A does not change account B
- findings are written down with any caveats

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)
- new: `docs/SPIKE_CLAUDE_CONFIG_DIR.md`

Checklist by file:

- `docs/SPIKE_CLAUDE_CONFIG_DIR.md`
  - record tested commands
  - record observed file layout
  - record success or fallback decision
- `tests/integration/test-provider-switch.sh`
  - add temporary-path test scaffolding if feasible

Dependency:

- none

Fallback if rejected:

- snapshot/copy full Claude state per account instead of relying on `CLAUDE_CONFIG_DIR`

### Phase 1: Multi-Account Foundation

#### Issue 1.1 - Add account state store and path resolution

Goal:

- introduce account registry and active-account state without breaking current single-account behavior

Tasks:

- add state directory under `~/.claude-switcher`
- add `accounts.json` and `state.json`
- create helpers to resolve:
  - active account
  - instance directory
  - settings path
  - backup directory
- preserve compatibility by auto-migrating the current default config into `default`

Acceptance Criteria:

- fresh install creates state files on first use
- existing users are migrated into a default account
- all settings writes go through path-resolution helpers

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [scripts/install.sh](/home/renato/workspace/claude-code-switcher/scripts/install.sh)
- [tests/unit/test-validation.sh](/home/renato/workspace/claude-code-switcher/tests/unit/test-validation.sh)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)

Checklist by file:

- `bin/claude-switch`
  - add state root constants
  - add JSON initialization helpers
  - add instance path resolution helpers
  - replace hardcoded `SETTINGS` and `BACKUP_DIR` writes
- `scripts/install.sh`
  - create `~/.claude-switcher`
  - document migration behavior
- `tests/unit/test-validation.sh`
  - cover path resolution helpers
- `tests/integration/test-provider-switch.sh`
  - cover migration into `default`
  - cover per-account backup locations
- `README.md`
  - explain account-aware storage

Dependency:

- Issue 0.1

#### Issue 1.2 - Add account lifecycle commands

Goal:

- make accounts a first-class CLI concept

Commands:

- `claude-switch account create <name>`
- `claude-switch account list`
- `claude-switch account use <name>`
- `claude-switch account current`
- `claude-switch account rename <old> <new>`
- `claude-switch account delete <name>`

Acceptance Criteria:

- users can create, switch, list, rename, and delete accounts
- active account persists between shell sessions
- delete refuses to remove the last remaining account unless explicitly forced later

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [config/aliases.sh](/home/renato/workspace/claude-code-switcher/config/aliases.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)

Checklist by file:

- `bin/claude-switch`
  - add account subcommand dispatcher
  - validate account names
  - update `status` output with active account
- `config/aliases.sh`
  - add optional aliases for `account current` and `account list`
- `README.md`
  - add account command examples
- `tests/integration/test-provider-switch.sh`
  - test create/use/list/delete flows

Dependency:

- Issue 1.1

### Phase 2: Claude Pro Account Login and Import

#### Issue 2.1 - Add account login flow

Goal:

- let users authenticate a new Claude Pro account into an isolated instance directory

Commands:

- `claude-switch account login <name>`
- `claude-switch account test <name>`

Tasks:

- launch Claude Code with the target instance environment
- guide the user through manual login in that instance
- implement a lightweight post-login validation

Acceptance Criteria:

- logging into `personal` does not change `work`
- `account test` can detect whether the instance appears authenticated
- failure modes are clear when Claude CLI is missing or login is incomplete

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [scripts/config-wizard.sh](/home/renato/workspace/claude-code-switcher/scripts/config-wizard.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)

Checklist by file:

- `bin/claude-switch`
  - add login launcher
  - add account auth validation helper
- `scripts/config-wizard.sh`
  - offer account login during setup
- `README.md`
  - add multi-account Claude Pro setup instructions
- `tests/integration/test-provider-switch.sh`
  - add non-destructive account auth smoke tests where feasible

Dependency:

- Issue 1.2

#### Issue 2.2 - Add account import from current config

Goal:

- make it easy to convert an existing local Claude setup into a named account

Command:

- `claude-switch account import-current <name>`

Acceptance Criteria:

- importing the current local setup creates a usable account directory
- import is non-destructive
- import refuses to overwrite an existing account unless a force path is added later

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)

Checklist by file:

- `bin/claude-switch`
  - add import command
  - add safe-copy helper
- `README.md`
  - add migration examples
- `tests/integration/test-provider-switch.sh`
  - verify import copies settings and state into a new account

Dependency:

- Issue 2.1

### Phase 3: Account-Aware Claude Launcher

#### Issue 3.1 - Add `exec` command

Goal:

- run Claude with the active account and optional provider switch in one command

Command:

- `claude-switch exec [provider[:model]] -- [claude args]`

Behavior:

- if a provider is supplied, switch the active account first
- then launch Claude with the account-specific environment

Acceptance Criteria:

- `account use work` followed by `claude-switch exec` launches `work`
- `claude-switch exec ollama:qwen3-coder:14b -- -p "hello"` applies the switch then launches
- two terminals can run different accounts concurrently

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [config/aliases.sh](/home/renato/workspace/claude-code-switcher/config/aliases.sh)
- [scripts/install.sh](/home/renato/workspace/claude-code-switcher/scripts/install.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)

Checklist by file:

- `bin/claude-switch`
  - parse `exec`
  - forward args after `--`
  - inject account environment
- `config/aliases.sh`
  - add `claude-active` alias or function
  - keep shell override opt-in
- `scripts/install.sh`
  - prompt for optional alias integration
- `README.md`
  - document launcher patterns

Dependency:

- Issue 2.2

### Phase 4: Global and Project Scope

#### Issue 4.1 - Add scope-aware settings resolution

Goal:

- support account-level global settings and per-project local overrides

Commands:

- `claude-switch global <provider>`
- `claude-switch project <provider>`
- `claude-switch reset project`
- `claude-switch where`

Acceptance Criteria:

- project scope writes to a local config location instead of the instance global file
- `where` shows account, scope, and target config path
- users can clear project overrides without deleting the account global settings

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [docs/SETUP.md](/home/renato/workspace/claude-code-switcher/docs/SETUP.md)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)

Checklist by file:

- `bin/claude-switch`
  - add scope parsing
  - add project target resolution
  - add `where`
- `README.md`
  - add project examples
- `docs/SETUP.md`
  - document local override behavior
- `tests/integration/test-provider-switch.sh`
  - test global/project separation

Dependency:

- Issue 3.1

### Phase 5: Diagnostics

#### Issue 5.1 - Add `doctor`

Goal:

- provide one diagnostic command for the whole installation

Commands:

- `claude-switch doctor`
- `claude-switch doctor --json`

Checks:

- `jq` installed
- `claude` installed
- state files exist and parse correctly
- active account exists
- settings file permissions
- account auth appears valid
- provider-specific local checks for Ollama and LM Studio

Acceptance Criteria:

- `doctor` reports actionable failures
- `doctor --json` returns machine-readable status
- broken state files are surfaced clearly

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [tests/unit/test-validation.sh](/home/renato/workspace/claude-code-switcher/tests/unit/test-validation.sh)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)

Checklist by file:

- `bin/claude-switch`
  - add diagnostic runner
  - add JSON output mode
- `tests/unit/test-validation.sh`
  - cover state parsing failures
  - cover account validation failures
- `tests/integration/test-provider-switch.sh`
  - test `doctor` in healthy and broken setups
- `README.md`
  - document `doctor`

Dependency:

- Issue 4.1

### Phase 6: Provider Presets and `update-config`

#### Issue 6.1 - Extract provider metadata from hardcoded `case` blocks

Goal:

- move model mappings and provider metadata into versioned config files

Tasks:

- create `config/providers.json`
- keep provider application logic in Bash
- read per-provider model maps, base URL, auth env, and aliases from data

Acceptance Criteria:

- supported provider definitions are loaded from `config/providers.json`
- adding or changing model mappings does not require editing every `case`
- provider switching behavior remains backward compatible

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- new: `config/providers.json`
- [tests/unit/test-model-mapping.sh](/home/renato/workspace/claude-code-switcher/tests/unit/test-model-mapping.sh)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)

Checklist by file:

- `bin/claude-switch`
  - add preset loading helpers
  - preserve special handling for local providers
- `config/providers.json`
  - define current built-in providers
- `tests/unit/test-model-mapping.sh`
  - validate JSON-driven mappings
- `README.md`
  - explain preset updates

Dependency:

- Issue 5.1

#### Issue 6.2 - Add `update-config`

Goal:

- update provider presets independently from the installed script

Command:

- `claude-switch update-config`

Acceptance Criteria:

- preset updates can be applied without replacing the main executable
- update failure does not corrupt the current local preset file
- users can see current preset version

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- [scripts/update.sh](/home/renato/workspace/claude-code-switcher/scripts/update.sh)
- new: `config/providers.version`
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)

Checklist by file:

- `bin/claude-switch`
  - add preset version command or display
  - add `update-config`
- `scripts/update.sh`
  - split binary update and preset update responsibilities
- `config/providers.version`
  - add initial preset version metadata
- `README.md`
  - document preset updates

Dependency:

- Issue 6.1

### Phase 7: Profiles and Custom Providers

#### Issue 7.1 - Add named profiles

Goal:

- let users save reusable combinations of account, provider, model, and scope

Commands:

- `claude-switch profile save <name>`
- `claude-switch profile use <name>`
- `claude-switch profile list`
- `claude-switch profile delete <name>`

Acceptance Criteria:

- a profile can reapply account, provider, model, and scope in one command
- profiles survive reinstalls because they live in user state

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- new: `config/profile.schema.json`
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [tests/integration/test-provider-switch.sh](/home/renato/workspace/claude-code-switcher/tests/integration/test-provider-switch.sh)

Checklist by file:

- `bin/claude-switch`
  - add profile CRUD
  - add profile apply logic
- `config/profile.schema.json`
  - define persisted profile shape
- `README.md`
  - add example workflows
- `tests/integration/test-provider-switch.sh`
  - test profile save/use/delete

Dependency:

- Issue 6.2

#### Issue 7.2 - Add declarative custom providers

Goal:

- let advanced users add Anthropic-compatible or OpenAI-compatible providers without patching the script

Commands:

- `claude-switch provider add`
- `claude-switch provider list`
- `claude-switch provider remove <name>`

Acceptance Criteria:

- users can define a provider with endpoint, auth env, protocol, and model mapping
- custom providers appear in `list`, `models`, and provider switching
- invalid provider definitions are rejected with clear errors

Files:

- [bin/claude-switch](/home/renato/workspace/claude-code-switcher/bin/claude-switch)
- new: `config/provider.schema.json`
- [docs/PROVIDERS.md](/home/renato/workspace/claude-code-switcher/docs/PROVIDERS.md)
- [README.md](/home/renato/workspace/claude-code-switcher/README.md)
- [tests/unit/test-validation.sh](/home/renato/workspace/claude-code-switcher/tests/unit/test-validation.sh)

Checklist by file:

- `bin/claude-switch`
  - merge built-in and user-defined providers
  - validate custom definitions before save
- `config/provider.schema.json`
  - define valid provider structure
- `docs/PROVIDERS.md`
  - add custom provider examples
- `README.md`
  - add quick-start example
- `tests/unit/test-validation.sh`
  - test schema validation and rejection cases

Dependency:

- Issue 7.1

## Cross-Cutting Refactors

These are not separate releases, but they should be scheduled as part of the work above.

### Refactor A - Command parsing cleanup

Current risk:

- the main `case` block and provider dispatch in `bin/claude-switch` are already large

Needed changes:

- isolate command parsing helpers
- isolate account commands from provider commands
- isolate output rendering from mutation logic

### Refactor B - Test fixture isolation

Current risk:

- tests are built around a single settings target

Needed changes:

- move to account-aware fixtures
- support per-test temp state roots
- support project scope fixtures

### Refactor C - Stable machine-readable output

Needed changes:

- add `--json` support to future commands that are likely to be scripted:
  - `status`
  - `doctor`
  - `account current`
  - `where`

## Open Questions

These should be resolved during the first two phases:

1. Is `CLAUDE_CONFIG_DIR` stable enough across Claude Code versions?
2. Which files inside an isolated Claude config directory are required for a healthy session?
3. Does Claude Code keep any account-critical state outside the config directory?
4. What is the correct local project config path for project-scoped overrides in practice?
5. Should the installer offer an opt-in `claude` wrapper alias, or keep `claude-switch exec` explicit?

## Definition of Done

A phase is complete when:

- commands are implemented
- tests cover the happy path and the main failure modes
- docs are updated
- migration behavior is explicit
- no existing provider regression is introduced for single-account users
