#!/bin/bash
# Integration tests for provider switching
# Tests the full apply_config() function with actual file manipulation

# Setup: Create a fresh test settings file before each test
# Note: SETTINGS is readonly, so we modify its content directly
setup_test_settings() {
    cat > "$SETTINGS" << 'EOF'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "old-token",
    "ANTHROPIC_BASE_URL": "https://old.provider.com/api",
    "ANTHROPIC_MODEL": "old-model"
  }
}
EOF
}

# Test: Switching to claude removes auth token and base URL
test_switch_to_claude() {
    setup_test_settings

    # Mock the confirmation (we'll apply directly)
    apply_config "claude" ""

    # Verify settings were updated correctly
    local auth_token
    local base_url
    auth_token=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // "null"' "$SETTINGS")
    base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "null"' "$SETTINGS")

    # Both should be null or not present
    if [ "$auth_token" != "null" ] && [ -n "$auth_token" ]; then
        echo -e "${RED}✗${NC} ANTHROPIC_AUTH_TOKEN should be null for claude"
        return 1
    fi

    if [ "$base_url" != "null" ] && [ -n "$base_url" ]; then
        echo -e "${RED}✗${NC} ANTHROPIC_BASE_URL should be null for claude"
        return 1
    fi

    return 0
}

# Test: Switching to zai sets correct config
test_switch_to_zai() {
    setup_test_settings

    # Set required API key
    export ZAI_API_KEY="test-zai-key"

    apply_config "zai" ""

    # Verify settings
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-zai-key" "Auth token should be set" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "https://api.z.ai/api/anthropic" "Base URL should be Z.AI" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL // \"null\"" "null" "Opus model should not be forced for Z.AI" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL // \"null\"" "null" "Sonnet model should not be forced for Z.AI" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL // \"null\"" "null" "Haiku model should not be forced for Z.AI" || return 1

    unset ZAI_API_KEY
}

# Test: Switching to zai respects legacy GLM_API_KEY
test_switch_to_zai_legacy_key() {
    setup_test_settings

    # Set legacy key
    export GLM_API_KEY="test-glm-key"
    unset ZAI_API_KEY

    apply_config "zai" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-glm-key" "Should use legacy GLM_API_KEY" || return 1

    unset GLM_API_KEY
}

test_switch_to_zai_refreshes_legacy_model_overrides() {
    local temp_home
    local command_output
    temp_home=$(create_test_home)

    cat > "$temp_home/.claude/settings.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "test-zai-key",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-flash"
  }
}
EOF

    command_output=$(HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai 2>&1) || return 1

    assert_contains "$command_output" "Refreshing:" || return 1
    assert_json_key "$temp_home/.claude/settings.json" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL // \"null\"" "null" "Legacy Opus override should be removed for Z.AI" || return 1
    assert_json_key "$temp_home/.claude/settings.json" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL // \"null\"" "null" "Legacy Sonnet override should be removed for Z.AI" || return 1
    assert_json_key "$temp_home/.claude/settings.json" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL // \"null\"" "null" "Legacy Haiku override should be removed for Z.AI" || return 1

    rm -rf "$temp_home"
}

test_switch_reads_provider_key_from_api_keys_file_without_shell_source() {
    local temp_home
    temp_home=$(create_test_home)

    cat > "$temp_home/.claude/api-keys.env" << 'EOF'
# Keys loaded from file only
export ZAI_API_KEY="file-zai-key"
EOF

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" --yes zai > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_AUTH_TOKEN' "file-zai-key" "Switch should read provider keys directly from api-keys.env" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Switch should still apply the selected provider mapping" || return 1

    rm -rf "$temp_home"
}

test_provider_catalog_drives_model_presets() {
    local temp_home
    local temp_config
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" status > /dev/null || return 1
    temp_config="$temp_home/.claude-switcher/providers.json"

    jq '.providers.deepseek.models.opus = "custom-deepseek-opus" |
        .providers.deepseek.models.sonnet = "custom-deepseek-sonnet" |
        .providers.deepseek.models.haiku = "custom-deepseek-haiku"' \
        "$temp_config" > "$temp_config.tmp" && mv "$temp_config.tmp" "$temp_config" || return 1

    HOME="$temp_home" DEEPSEEK_API_KEY="test-deepseek-key" bash "$PROJECT_DIR/bin/claude-switch" --yes deepseek > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_DEFAULT_OPUS_MODEL' "custom-deepseek-opus" "Provider catalog should define the Opus preset" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_DEFAULT_SONNET_MODEL' "custom-deepseek-sonnet" "Provider catalog should define the Sonnet preset" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_DEFAULT_HAIKU_MODEL' "custom-deepseek-haiku" "Provider catalog should define the Haiku preset" || return 1

    rm -rf "$temp_home"
}

test_update_config_replaces_provider_catalog() {
    local temp_home
    local remote_dir
    local remote_file
    local providers_file
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" status > /dev/null || return 1
    providers_file="$temp_home/.claude-switcher/providers.json"

    remote_dir=$(mktemp -d)
    remote_file="$remote_dir/providers.json"
    cat > "$remote_file" << 'EOF'
{
  "version": 99,
  "providers": {
    "anthropic-api": {
      "base_url": "https://api.anthropic.com",
      "auth_env": ["ANTHROPIC_API_KEY"],
      "mapping_strategy": "fixed",
      "models": {
        "opus": "custom-opus",
        "sonnet": "custom-sonnet",
        "haiku": "custom-haiku"
      }
    }
  }
}
EOF

    CLAUDE_SWITCHER_CONFIG_URL="file://$remote_file" HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" update-config > /dev/null || return 1

    assert_json_key "$providers_file" '.version' "99" "update-config should replace the local provider catalog" || return 1
    assert_json_key "$providers_file" '.providers["anthropic-api"].models.opus' "custom-opus" "update-config should install the downloaded catalog" || return 1
    assert_file_exists "$providers_file.backup" "update-config should keep a backup of the previous provider catalog" || return 1

    rm -rf "$temp_home" "$remote_dir"
}

test_update_config_falls_back_to_local_checkout_copy() {
    local temp_home
    local providers_file
    local command_output
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" status > /dev/null || return 1
    providers_file="$temp_home/.claude-switcher/providers.json"

    command_output=$(HOME="$temp_home" CLAUDE_SWITCHER_UPDATE_BASE_URL="https://example.invalid/claude-code-switcher" bash "$PROJECT_DIR/bin/claude-switch" update-config 2>&1) || return 1

    assert_contains "$command_output" "using local checkout copy" || return 1
    assert_file_exists "$providers_file" || return 1
    assert_equals "1" "$(jq -r '.version' "$providers_file")" "Local fallback should install the bundled provider catalog" || return 1

    rm -rf "$temp_home"
}

test_custom_provider_add_list_and_switch() {
    local temp_home
    local list_output
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" provider add acme \
        --base-url "https://acme.example/api/anthropic" \
        --auth-env "ACME_API_KEY" \
        --mapping fixed \
        --display-name "Acme AI" \
        --opus "acme-opus" \
        --sonnet "acme-sonnet" \
        --haiku "acme-haiku" > /dev/null || return 1

    list_output=$(HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" provider list 2>&1) || return 1
    assert_contains "$list_output" "Acme AI" || return 1
    assert_contains "$list_output" "acme" || return 1
    assert_contains "$list_output" "mapping=fixed" || return 1

    HOME="$temp_home" ACME_API_KEY="test-acme-key" bash "$PROJECT_DIR/bin/claude-switch" --yes acme > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_AUTH_TOKEN' "test-acme-key" "Custom provider should set the auth token" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://acme.example/api/anthropic" "Custom provider should set the base URL" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_DEFAULT_OPUS_MODEL' "acme-opus" "Custom provider should set Opus mapping" || return 1

    rm -rf "$temp_home"
}

test_profile_save_and_use_reapplies_account_and_provider() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    HOME="$temp_home" DEEPSEEK_API_KEY="test-deepseek-key" bash "$PROJECT_DIR/bin/claude-switch" --yes deepseek > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save work-deepseek > /dev/null || return 1

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use default > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" --yes claude > /dev/null || return 1
    HOME="$temp_home" DEEPSEEK_API_KEY="test-deepseek-key" bash "$PROJECT_DIR/bin/claude-switch" profile use work-deepseek > /dev/null || return 1

    assert_json_key "$temp_home/.claude-switcher/state.json" '.active_account' "work" "Using a profile should switch to the saved account" || return 1
    assert_json_key "$temp_home/.claude-switcher/instances/work/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.deepseek.com/anthropic" "Using a profile should reapply the saved provider" || return 1

    rm -rf "$temp_home"
}

test_profile_save_rejects_unexpected_provider() {
    local temp_home
    local command_output
    temp_home=$(create_test_home)

    HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai > /dev/null || return 1
    command_output=$(HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save mismatch --provider acme 2>&1) && return 1

    assert_contains "$command_output" "Expected: acme" || return 1
    assert_contains "$command_output" "Current:  zai" || return 1

    rm -rf "$temp_home"
}

test_profile_save_requires_yes_to_overwrite() {
    local temp_home
    local command_output
    temp_home=$(create_test_home)

    HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save work-zai --provider zai --yes > /dev/null || return 1
    command_output=$(printf 'n\n' | HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save work-zai 2>&1) && return 1

    assert_contains "$command_output" "Existing: yes" || return 1
    assert_contains "$command_output" "Operation cancelled" || return 1

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save work-zai --yes > /dev/null || return 1

    rm -rf "$temp_home"
}

test_profile_save_and_use_reapplies_project_scope() {
    local temp_home
    local project_dir
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    (
        cd "$project_dir" &&
        HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" project --yes zai > /dev/null &&
        HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" profile save project-zai > /dev/null
    ) || return 1

    rm -f "$project_dir/.claude/settings.local.json"

    HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" profile use project-zai > /dev/null || return 1

    assert_file_exists "$project_dir/.claude/settings.local.json" "Using a project profile should recreate the local override" || return 1
    assert_json_key "$project_dir/.claude/settings.local.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Using a project profile should target the saved project root" || return 1

    rm -rf "$temp_home"
}

# Test: Switching to zai fails without API key
test_switch_to_zai_no_key() {
    setup_test_settings

    unset ZAI_API_KEY
    unset GLM_API_KEY

    # Should fail
    if apply_config "zai" "" 2>/dev/null; then
        echo -e "${RED}✗${NC} Should fail without API key"
        return 1
    fi

    return 0
}

# Test: Switching to deepseek sets correct config
test_switch_to_deepseek() {
    setup_test_settings

    export DEEPSEEK_API_KEY="test-deepseek-key"

    apply_config "deepseek" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-deepseek-key" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "https://api.deepseek.com/anthropic" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "deepseek-chat" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL" "deepseek-chat" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL" "deepseek-chat" || return 1

    unset DEEPSEEK_API_KEY
}

# Test: Switching to kimi sets correct config
test_switch_to_kimi() {
    setup_test_settings

    export KIMI_API_KEY="test-kimi-key"

    apply_config "kimi" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-kimi-key" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "https://api.moonshot.ai/anthropic" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "moonshot-v1-128k" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL" "moonshot-v1-32k" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL" "moonshot-v1-8k" || return 1

    unset KIMI_API_KEY
}

# Test: Switching to qwen sets correct config
test_switch_to_qwen() {
    setup_test_settings

    export SILICONFLOW_API_KEY="test-qwen-key"

    apply_config "qwen" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-qwen-key" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "https://api.siliconflow.cn/v1/anthropic" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "Qwen/Qwen2.5-Coder-32B-Instruct" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL" "Qwen/Qwen2.5-Coder-14B-Instruct" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL" "Qwen/Qwen2.5-Coder-7B-Instruct" || return 1

    unset SILICONFLOW_API_KEY
}

# Test: Switching to openrouter with explicit model
test_switch_to_openrouter_with_model() {
    setup_test_settings

    export OPENROUTER_API_KEY="test-or-key"

    apply_config "openrouter" "anthropic/claude-opus-4.6"

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "test-or-key" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "https://openrouter.ai/api" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "anthropic/claude-opus-4.6" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL" "anthropic/claude-opus-4.6" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL" "anthropic/claude-opus-4.6" || return 1

    unset OPENROUTER_API_KEY
}

# Test: Switching to openrouter with env var default
test_switch_to_openrouter_with_env_default() {
    setup_test_settings

    export OPENROUTER_API_KEY="test-or-key"
    export OPENROUTER_DEFAULT_MODEL="custom/model-name"

    apply_config "openrouter" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "custom/model-name" || return 1

    unset OPENROUTER_API_KEY
    unset OPENROUTER_DEFAULT_MODEL
}

# Test: Switching to openrouter fails without model
test_switch_to_openrouter_no_model() {
    setup_test_settings

    export OPENROUTER_API_KEY="test-or-key"
    unset OPENROUTER_DEFAULT_MODEL

    if apply_config "openrouter" "" 2>/dev/null; then
        echo -e "${RED}✗${NC} Should fail without model specified"
        return 1
    fi

    unset OPENROUTER_API_KEY
    return 0
}

# Test: Switching to lmstudio sets correct config
test_switch_to_lmstudio() {
    setup_test_settings

    # Mock the LM Studio server check by having curl succeed
    # We'll skip this test if server is not actually available
    if ! curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
        return 0  # Skip test
    fi

    apply_config "lmstudio" ""

    assert_json_key "$SETTINGS" ".env.ANTHROPIC_AUTH_TOKEN" "lmstudio" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_BASE_URL" "http://localhost:1234/v1" || return 1
}

# Test: Backup file is created on switch
test_backup_created() {
    setup_test_settings

    export ZAI_API_KEY="test-key"

    # Clear backup directory
    rm -rf "${BACKUP_DIR:?}"/*
    mkdir -p "$BACKUP_DIR"

    apply_config "claude" ""

    # Check that backup was created
    local backups
    backups=$(ls -1 "$BACKUP_DIR" 2>/dev/null | grep -c "settings.json.backup-" || true)

    if [ "$backups" -lt 1 ]; then
        echo -e "${RED}✗${NC} No backup file created"
        return 1
    fi

    unset ZAI_API_KEY
}

# Test: Switching providers clears stale model settings
test_clear_stale_models() {
    setup_test_settings

    # Add stale model settings
    local tmp_settings
    tmp_settings=$(mktemp)
    jq '.env.ANTHROPIC_MODEL = "stale-model" |
        .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "stale-opus" |
        .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "stale-sonnet" |
        .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "stale-haiku"' \
        "$SETTINGS" > "$tmp_settings"
    mv "$tmp_settings" "$SETTINGS"

    export ZAI_API_KEY="test-key"
    apply_config "zai" ""

    # Old ANTHROPIC_MODEL should be removed
    local old_model
    old_model=$(jq -r '.env.ANTHROPIC_MODEL // "null"' "$SETTINGS")

    if [ "$old_model" != "null" ]; then
        echo -e "${RED}✗${NC} Stale ANTHROPIC_MODEL not cleared"
        return 1
    fi

    unset ZAI_API_KEY
}

test_switch_clears_stale_provider_connection_fields() {
    local temp_home
    temp_home=$(create_test_home)

    cat > "$temp_home/.claude/settings.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": "stale-api-key",
    "ANTHROPIC_AUTH_TOKEN": "stale-auth-token",
    "ANTHROPIC_BASE_URL": "https://stale.example/api"
  }
}
EOF

    HOME="$temp_home" ZAI_API_KEY="test-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_AUTH_TOKEN' "test-key" "Switch should set the current provider auth token" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Switch should set the current provider base URL" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_API_KEY // "null"' "null" "Switch should clear stale ANTHROPIC_API_KEY from previous providers" || return 1

    rm -rf "$temp_home"
}

create_test_home() {
    local temp_home
    temp_home=$(mktemp -d)
    mkdir -p "$temp_home/.claude/backups"
    cat > "$temp_home/.claude/settings.json" << 'EOF'
{
  "env": {}
}
EOF
    echo "$temp_home"
}

create_test_project() {
    local temp_home="$1"
    local project_dir="$temp_home/project"
    mkdir -p "$project_dir"
    echo "$project_dir"
}

create_mock_claude() {
    local temp_home="$1"
    mkdir -p "$temp_home/bin"
    cat > "$temp_home/bin/claude" << 'EOF'
#!/bin/bash
echo "${CLAUDE_CONFIG_DIR:-}" > "${MOCK_CLAUDE_LOG}"
if [ -n "${MOCK_CLAUDE_ARGS_LOG:-}" ]; then
  printf '%s\n' "$@" > "${MOCK_CLAUDE_ARGS_LOG}"
fi
if [ -n "${MOCK_CLAUDE_ENV_LOG:-}" ]; then
  {
    printf 'ZAI_API_KEY=%s\n' "${ZAI_API_KEY:-}"
    printf 'GLM_API_KEY=%s\n' "${GLM_API_KEY:-}"
    printf 'DEEPSEEK_API_KEY=%s\n' "${DEEPSEEK_API_KEY:-}"
    printf 'ANTHROPIC_API_KEY=%s\n' "${ANTHROPIC_API_KEY:-}"
    printf 'ANTHROPIC_AUTH_TOKEN=%s\n' "${ANTHROPIC_AUTH_TOKEN:-}"
    printf 'ANTHROPIC_BASE_URL=%s\n' "${ANTHROPIC_BASE_URL:-}"
    printf 'ANTHROPIC_MODEL=%s\n' "${ANTHROPIC_MODEL:-}"
    printf 'ANTHROPIC_DEFAULT_OPUS_MODEL=%s\n' "${ANTHROPIC_DEFAULT_OPUS_MODEL:-}"
    printf 'ANTHROPIC_DEFAULT_SONNET_MODEL=%s\n' "${ANTHROPIC_DEFAULT_SONNET_MODEL:-}"
    printf 'ANTHROPIC_DEFAULT_HAIKU_MODEL=%s\n' "${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}"
    printf 'OPENROUTER_DEFAULT_MODEL=%s\n' "${OPENROUTER_DEFAULT_MODEL:-}"
  } > "${MOCK_CLAUDE_ENV_LOG}"
fi
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
mkdir -p "${CLAUDE_CONFIG_DIR}"
cat > "${CLAUDE_CONFIG_DIR}/.claude.json" << 'JSON'
{
  "oauthAccount": {
    "emailAddress": "mock@example.com"
  }
}
JSON
fi
EOF
    chmod +x "$temp_home/bin/claude"
}

test_default_account_uses_legacy_claude_dir() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" status > /dev/null || return 1

    assert_file_exists "$temp_home/.claude-switcher/accounts.json" || return 1
    assert_file_exists "$temp_home/.claude-switcher/providers.json" || return 1
    assert_json_key "$temp_home/.claude-switcher/accounts.json" '.accounts.default.path' "$temp_home/.claude" "Default account should point to legacy ~/.claude" || return 1
    assert_json_key "$temp_home/.claude-switcher/accounts.json" '.accounts.default.legacy' "true" "Default account should be marked legacy" || return 1
    assert_json_key "$temp_home/.claude-switcher/state.json" '.active_account' "default" "Default account should be active" || return 1

    rm -rf "$temp_home"
}

test_account_create_and_use_isolated_instance() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1

    assert_file_exists "$temp_home/.claude-switcher/instances/work/settings.json" || return 1
    assert_json_key "$temp_home/.claude-switcher/accounts.json" '.accounts.work.path' "$temp_home/.claude-switcher/instances/work" "New account should use an isolated path" || return 1
    assert_json_key "$temp_home/.claude-switcher/state.json" '.active_account' "work" "Active account should switch to work" || return 1

    rm -rf "$temp_home"
}

test_account_rename_updates_registry_and_path() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account rename work office > /dev/null || return 1

    assert_file_exists "$temp_home/.claude-switcher/instances/office/settings.json" || return 1
    assert_json_key "$temp_home/.claude-switcher/accounts.json" '.accounts.office.path' "$temp_home/.claude-switcher/instances/office" "Renamed account should update registry path" || return 1

    rm -rf "$temp_home"
}

test_account_delete_removes_isolated_instance() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account delete work > /dev/null || return 1

    if [ -e "$temp_home/.claude-switcher/instances/work" ]; then
        echo -e "${RED}✗${NC} Deleted account directory should be removed"
        return 1
    fi

    assert_json_key "$temp_home/.claude-switcher/state.json" '.active_account' "default" "Deleting the only isolated account should keep default active" || return 1

    rm -rf "$temp_home"
}

test_provider_switch_on_default_account_preserves_legacy_behavior() {
    local temp_home
    temp_home=$(create_test_home)

    printf 'y\n' | HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" zai > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Default account should still update ~/.claude/settings.json" || return 1

    rm -rf "$temp_home"
}

test_provider_switch_on_isolated_account_writes_to_instance_settings() {
    local temp_home
    temp_home=$(create_test_home)

    cat > "$temp_home/.claude/settings.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://legacy.example"
  }
}
EOF

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    printf 'y\n' | HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" zai > /dev/null || return 1

    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://legacy.example" "Legacy ~/.claude/settings.json should remain unchanged" || return 1
    assert_json_key "$temp_home/.claude-switcher/instances/work/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Isolated account should write into its own settings.json" || return 1

    rm -rf "$temp_home"
}

test_provider_switch_accepts_yes_flag() {
    local temp_home
    temp_home=$(create_test_home)
    local command_output

    command_output=$(HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai 2>&1) || return 1

    assert_contains "$command_output" "Confirmation: auto-approved via --yes" || return 1
    assert_json_key "$temp_home/.claude/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "The --yes flag should skip the provider confirmation prompt" || return 1

    rm -rf "$temp_home"
}

test_project_switch_writes_local_override() {
    local temp_home
    local project_dir
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    (
        cd "$project_dir" &&
        HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" project --yes zai > /dev/null
    ) || return 1

    assert_json_key "$temp_home/.claude-switcher/instances/work/settings.json" '.env.ANTHROPIC_BASE_URL // "oauth"' "oauth" "Project overrides should not mutate the account global settings" || return 1
    assert_json_key "$project_dir/.claude/settings.local.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Project scope should write to .claude/settings.local.json" || return 1

    rm -rf "$temp_home"
}

test_project_claude_writes_null_overrides() {
    local temp_home
    local project_dir
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" --yes zai > /dev/null || return 1
    (
        cd "$project_dir" &&
        HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" project --yes claude > /dev/null
    ) || return 1

    if ! jq -e '.env.ANTHROPIC_AUTH_TOKEN == null' "$project_dir/.claude/settings.local.json" > /dev/null 2>&1; then
        echo -e "${RED}✗${NC} Project claude should null out the inherited auth token"
        return 1
    fi

    if ! jq -e '.env.ANTHROPIC_BASE_URL == null' "$project_dir/.claude/settings.local.json" > /dev/null 2>&1; then
        echo -e "${RED}✗${NC} Project claude should null out the inherited base URL"
        return 1
    fi

    rm -rf "$temp_home"
}

test_status_and_where_use_project_override() {
    local temp_home
    local project_dir
    local status_output
    local where_output
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.local.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}
EOF

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1

    status_output=$(
        cd "$project_dir" &&
        HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" status
    ) || return 1
    where_output=$(
        cd "$project_dir" &&
        HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" where
    ) || return 1

    assert_contains "$status_output" "Scope: project" || return 1
    assert_contains "$status_output" "Settings: $project_dir/.claude/settings.local.json" || return 1
    assert_contains "$status_output" "Provider: " || return 1
    assert_contains "$status_output" "Z.AI (GLM)" || return 1
    assert_contains "$where_output" "Project Override: yes" || return 1
    assert_contains "$where_output" "Effective Scope: project" || return 1
    assert_contains "$where_output" "Effective Settings: $project_dir/.claude/settings.local.json" || return 1

    rm -rf "$temp_home"
}

test_global_switch_ignores_project_override_target() {
    local temp_home
    local project_dir
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.local.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}
EOF

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    (
        cd "$project_dir" &&
        HOME="$temp_home" DEEPSEEK_API_KEY="test-deepseek-key" bash "$PROJECT_DIR/bin/claude-switch" global --yes deepseek > /dev/null
    ) || return 1

    assert_json_key "$temp_home/.claude-switcher/instances/work/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.deepseek.com/anthropic" "Global scope should update the account settings file" || return 1
    assert_json_key "$project_dir/.claude/settings.local.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Global scope should not overwrite the project-local override" || return 1

    rm -rf "$temp_home"
}

test_reset_project_removes_local_override() {
    local temp_home
    local project_dir
    local command_output
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")

    mkdir -p "$project_dir/.claude"
    cat > "$project_dir/.claude/settings.local.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}
EOF

    command_output=$(
        cd "$project_dir" &&
        HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" reset project
    ) || return 1

    if [ -f "$project_dir/.claude/settings.local.json" ]; then
        echo -e "${RED}✗${NC} Reset project should remove the local override file"
        return 1
    fi

    assert_contains "$command_output" "Removed project override" || return 1

    local backup_count
    backup_count=$(find "$project_dir/.claude/backups" -maxdepth 1 -type f -name 'settings.local.json.backup-*' | wc -l)
    assert_equals "1" "$backup_count" "Reset project should keep a backup of the removed override" || return 1

    rm -rf "$temp_home"
}

test_doctor_reports_healthy_environment() {
    local temp_home
    local command_output
    local jq_dir
    temp_home=$(create_test_home)
    create_mock_claude "$temp_home"
    jq_dir=$(dirname "$(command -v jq)")

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    cat > "$temp_home/.claude-switcher/instances/work/.claude.json" << 'EOF'
{
  "oauthAccount": {
    "emailAddress": "work@example.com"
  }
}
EOF

    command_output=$(PATH="$temp_home/bin:$jq_dir:/usr/bin:/bin" HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" doctor 2>&1) || return 1

    assert_contains "$command_output" "Doctor:" || return 1
    assert_contains "$command_output" "Account: work" || return 1
    assert_contains "$command_output" "jq" || return 1
    assert_contains "$command_output" "claude" || return 1
    assert_contains "$command_output" "auth" || return 1
    assert_contains "$command_output" "Summary:" || return 1
    assert_contains "$command_output" "healthy" || return 1

    rm -rf "$temp_home"
}

test_doctor_json_reports_broken_environment() {
    local temp_home
    local project_dir
    local json_output
    local jq_dir
    temp_home=$(create_test_home)
    project_dir=$(create_test_project "$temp_home")
    jq_dir=$(dirname "$(command -v jq)")

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    cat > "$temp_home/.claude-switcher/instances/work/settings.json" << 'EOF'
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}
EOF
    mkdir -p "$project_dir/.claude"
    printf '{\n' > "$project_dir/.claude/settings.local.json"

    json_output=$(
        cd "$project_dir" &&
        PATH="$jq_dir:/usr/bin:/bin" HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" doctor --json
    ) || true

    assert_equals "broken" "$(printf '%s\n' "$json_output" | jq -r '.status')" "Doctor JSON should report a broken environment when checks fail" || return 1
    assert_equals "fail" "$(printf '%s\n' "$json_output" | jq -r '.checks[] | select(.id == "claude") | .status')" "Doctor JSON should report missing Claude CLI" || return 1
    assert_equals "fail" "$(printf '%s\n' "$json_output" | jq -r '.checks[] | select(.id == "project_settings") | .status')" "Doctor JSON should report invalid project settings" || return 1
    assert_equals "warn" "$(printf '%s\n' "$json_output" | jq -r '.checks[] | select(.id == "auth") | .status')" "Doctor JSON should warn when no auth state exists for an API provider" || return 1

    rm -rf "$temp_home"
}

test_account_login_uses_claude_config_dir() {
    local temp_home
    temp_home=$(create_test_home)
    create_mock_claude "$temp_home"

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    MOCK_CLAUDE_LOG="$temp_home/mock-claude.log" PATH="$temp_home/bin:$PATH" HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account login work > /dev/null || return 1

    assert_json_key "$temp_home/.claude-switcher/instances/work/.claude.json" '.oauthAccount.emailAddress' "mock@example.com" "Login should create auth state in the isolated account root" || return 1

    local logged_dir
    logged_dir=$(cat "$temp_home/mock-claude.log")
    assert_equals "$temp_home/.claude-switcher/instances/work" "$logged_dir" "Login should launch Claude with CLAUDE_CONFIG_DIR set to the account path" || return 1

    rm -rf "$temp_home"
}

test_account_test_detects_authenticated_isolated_account() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    cat > "$temp_home/.claude-switcher/instances/work/.claude.json" << 'EOF'
{
  "oauthAccount": {
    "emailAddress": "work@example.com"
  }
}
EOF

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account test work > /dev/null || return 1

    rm -rf "$temp_home"
}

test_account_test_fails_without_auth_state() {
    local temp_home
    temp_home=$(create_test_home)

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1

    if HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account test work > /dev/null 2>&1; then
        echo -e "${RED}✗${NC} Account test should fail when there is no auth state"
        return 1
    fi

    rm -rf "$temp_home"
}

test_account_import_current_copies_legacy_state() {
    local temp_home
    temp_home=$(create_test_home)

    cat > "$temp_home/.claude.json" << 'EOF'
{
  "oauthAccount": {
    "emailAddress": "legacy@example.com"
  }
}
EOF
    cat > "$temp_home/.claude/policy-limits.json" << 'EOF'
{
  "max_requests": 10
}
EOF
    mkdir -p "$temp_home/.claude/cache" "$temp_home/.claude/plugins" "$temp_home/.claude/backups"
    printf 'cached\n' > "$temp_home/.claude/cache/changelog.md"
    printf 'plugin\n' > "$temp_home/.claude/plugins/blocklist.json"
    printf 'backup\n' > "$temp_home/.claude/backups/example.backup"

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account import-current imported > /dev/null || return 1

    assert_json_key "$temp_home/.claude-switcher/instances/imported/.claude.json" '.oauthAccount.emailAddress' "legacy@example.com" "Import should copy the current Claude auth file" || return 1
    assert_json_key "$temp_home/.claude-switcher/instances/imported/policy-limits.json" '.max_requests' "10" "Import should copy policy limits" || return 1
    assert_file_exists "$temp_home/.claude-switcher/instances/imported/cache/changelog.md" || return 1
    assert_file_exists "$temp_home/.claude-switcher/instances/imported/plugins/blocklist.json" || return 1
    assert_file_exists "$temp_home/.claude-switcher/instances/imported/backups/example.backup" || return 1

    rm -rf "$temp_home"
}

test_exec_uses_active_isolated_account_runtime() {
    local temp_home
    local temp_project_root
    temp_home=$(create_test_home)
    temp_project_root=$(create_test_project "$temp_home")
    create_mock_claude "$temp_home"

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    CLAUDE_SWITCH_PROJECT_ROOT="$temp_project_root" MOCK_CLAUDE_LOG="$temp_home/mock-claude.log" MOCK_CLAUDE_ARGS_LOG="$temp_home/mock-claude-args.log" PATH="$temp_home/bin:$PATH" HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" exec -- -p "hello world" > /dev/null || return 1

    assert_equals "$temp_home/.claude-switcher/instances/work" "$(cat "$temp_home/mock-claude.log")" "Exec should launch Claude with the isolated account runtime" || return 1

    local first_arg
    local second_arg
    first_arg=$(sed -n '1p' "$temp_home/mock-claude-args.log")
    second_arg=$(sed -n '2p' "$temp_home/mock-claude-args.log")
    assert_equals "-p" "$first_arg" "Exec should forward Claude CLI flags" || return 1
    assert_equals "hello world" "$second_arg" "Exec should forward Claude CLI values" || return 1

    rm -rf "$temp_home"
}

test_exec_can_switch_provider_before_launch() {
    local temp_home
    local temp_project_root
    temp_home=$(create_test_home)
    temp_project_root=$(create_test_project "$temp_home")
    create_mock_claude "$temp_home"
    local command_output

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1
    command_output=$(CLAUDE_SWITCH_PROJECT_ROOT="$temp_project_root" MOCK_CLAUDE_LOG="$temp_home/mock-claude.log" PATH="$temp_home/bin:$PATH" HOME="$temp_home" ZAI_API_KEY="test-zai-key" bash "$PROJECT_DIR/bin/claude-switch" exec --yes zai -- 2>&1) || return 1

    assert_json_key "$temp_home/.claude-switcher/instances/work/settings.json" '.env.ANTHROPIC_BASE_URL' "https://api.z.ai/api/anthropic" "Exec should switch the provider before launching Claude" || return 1
    assert_equals "$temp_home/.claude-switcher/instances/work" "$(cat "$temp_home/mock-claude.log")" "Exec should still launch with the isolated runtime" || return 1
    assert_contains "$command_output" "Confirmation: auto-approved via --yes" || return 1
    assert_contains "$command_output" "Launch Summary:" || return 1
    assert_contains "$command_output" "Account: work" || return 1
    assert_contains "$command_output" "Mode: isolated" || return 1
    assert_contains "$command_output" "Provider: Z.AI (GLM)" || return 1
    assert_contains "$command_output" "Settings: $temp_home/.claude-switcher/instances/work/settings.json" || return 1
    assert_contains "$command_output" "CLAUDE_CONFIG_DIR: $temp_home/.claude-switcher/instances/work" || return 1

    rm -rf "$temp_home"
}

test_exec_clears_stale_provider_env_before_launch() {
    local temp_home
    local temp_project_root
    local env_log
    temp_home=$(create_test_home)
    temp_project_root=$(create_test_project "$temp_home")
    create_mock_claude "$temp_home"

    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account create work > /dev/null || return 1
    HOME="$temp_home" bash "$PROJECT_DIR/bin/claude-switch" account use work > /dev/null || return 1

    CLAUDE_SWITCH_PROJECT_ROOT="$temp_project_root" \
    MOCK_CLAUDE_LOG="$temp_home/mock-claude.log" \
    MOCK_CLAUDE_ENV_LOG="$temp_home/mock-claude-env.log" \
    PATH="$temp_home/bin:$PATH" \
    HOME="$temp_home" \
    ZAI_API_KEY="test-zai-key" \
    GLM_API_KEY="legacy-glm-key" \
    DEEPSEEK_API_KEY="stale-deepseek-key" \
    ANTHROPIC_API_KEY="stale-anthropic-key" \
    ANTHROPIC_AUTH_TOKEN="stale-auth-token" \
    ANTHROPIC_BASE_URL="https://stale.example/api" \
    ANTHROPIC_MODEL="stale-model" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="stale-opus" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="stale-sonnet" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="stale-haiku" \
    OPENROUTER_DEFAULT_MODEL="stale/openrouter-model" \
    bash "$PROJECT_DIR/bin/claude-switch" exec --yes zai -- > /dev/null || return 1
    env_log=$(cat "$temp_home/mock-claude-env.log")

    assert_matches "$env_log" '(^|[[:space:]])ZAI_API_KEY=($|[[:space:]])' "Launch should unset ZAI_API_KEY for the child process" || return 1
    assert_matches "$env_log" '(^|[[:space:]])GLM_API_KEY=($|[[:space:]])' "Launch should unset GLM_API_KEY for the child process" || return 1
    assert_matches "$env_log" '(^|[[:space:]])DEEPSEEK_API_KEY=($|[[:space:]])' "Launch should unset other provider keys for the child process" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_API_KEY=($|[[:space:]])' "Launch should unset Anthropic API key overrides" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_AUTH_TOKEN=($|[[:space:]])' "Launch should unset routing token overrides" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_BASE_URL=($|[[:space:]])' "Launch should unset routing base URL overrides" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_MODEL=($|[[:space:]])' "Launch should unset model overrides" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_DEFAULT_OPUS_MODEL=($|[[:space:]])' "Launch should unset Opus override" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_DEFAULT_SONNET_MODEL=($|[[:space:]])' "Launch should unset Sonnet override" || return 1
    assert_matches "$env_log" '(^|[[:space:]])ANTHROPIC_DEFAULT_HAIKU_MODEL=($|[[:space:]])' "Launch should unset Haiku override" || return 1
    assert_matches "$env_log" '(^|[[:space:]])OPENROUTER_DEFAULT_MODEL=($|[[:space:]])' "Launch should unset OpenRouter model overrides" || return 1

    rm -rf "$temp_home"
}

# Test: Invalid provider fails gracefully
test_invalid_provider() {
    setup_test_settings

    if apply_config "nonexistent-provider" "" 2>/dev/null; then
        echo -e "${RED}✗${NC} Should fail for invalid provider"
        return 1
    fi

    return 0
}

# Test: Provider name normalization (anthropic -> claude, z.ai -> zai)
test_provider_normalization() {
    setup_test_settings

    # Test "anthropic" normalizes to "claude"
    apply_config "anthropic" ""

    local base_url
    base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "null"' "$SETTINGS")

    if [ "$base_url" != "null" ] && [ -n "$base_url" ]; then
        echo -e "${RED}✗${NC} 'anthropic' should normalize to 'claude'"
        return 1
    fi

    # Test "z.ai" normalizes to "zai"
    setup_test_settings
    export ZAI_API_KEY="test-key"
    apply_config "z.ai" ""

    base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "null"' "$SETTINGS")

    if [ "$base_url" != "https://api.z.ai/api/anthropic" ]; then
        echo -e "${RED}✗${NC} 'z.ai' should normalize to 'zai'"
        return 1
    fi

    unset ZAI_API_KEY
}

# Test: Settings file permissions are set to 600
test_settings_permissions() {
    setup_test_settings

    export ZAI_API_KEY="test-key"
    apply_config "zai" ""

    local perms
    perms=$(stat -c "%a" "$SETTINGS" 2>/dev/null || stat -f "%A" "$SETTINGS" 2>/dev/null)

    if [ "$perms" != "600" ]; then
        echo -e "${RED}✗${NC} Settings file should have 600 permissions, got $perms"
        return 1
    fi

    unset ZAI_API_KEY
}
