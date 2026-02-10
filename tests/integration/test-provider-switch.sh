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
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_OPUS_MODEL" "glm-4.7" "Opus model should be glm-4.7" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_SONNET_MODEL" "glm-4.7" "Sonnet model should be glm-4.7" || return 1
    assert_json_key "$SETTINGS" ".env.ANTHROPIC_DEFAULT_HAIKU_MODEL" "glm-4.5-flash" "Haiku model should be glm-4.5-flash" || return 1

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
