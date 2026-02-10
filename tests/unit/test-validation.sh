#!/bin/bash
# Unit tests for validation functions
# Tests validate_key(), validate_model_name(), check_ollama(), check_lmstudio()

# Helper: Create test settings and temporarily swap SETTINGS file
# Note: Since SETTINGS is readonly, we modify the file content directly
with_test_settings() {
    local content="$1"
    local test_cmd="$2"

    # Backup current settings
    cp "$SETTINGS" "${SETTINGS}.backup"

    # Write test content
    echo "$content" > "$SETTINGS"

    # Run test command
    eval "$test_cmd"
    local result=$?

    # Restore original settings
    mv "${SETTINGS}.backup" "$SETTINGS"

    return $result
}

# Test: get_current_config detects claude (oauth) correctly
test_current_config_claude() {
    local content='{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-ant-xxx"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "claude" "$result"
}

# Test: get_current_config detects zai correctly
test_current_config_zai() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "zai" "$result"
}

# Test: get_current_config detects deepseek correctly
test_current_config_deepseek() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "deepseek" "$result"
}

# Test: get_current_config detects kimi correctly
test_current_config_kimi() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.moonshot.ai/anthropic"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "kimi" "$result"
}

# Test: get_current_config detects qwen correctly
test_current_config_qwen() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.siliconflow.cn/v1/anthropic"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "qwen" "$result"
}

# Test: get_current_config detects openrouter correctly
test_current_config_openrouter() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://openrouter.ai/api"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "openrouter" "$result"
}

# Test: get_current_config detects ollama correctly
test_current_config_ollama() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:11434"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "ollama" "$result"
}

# Test: get_current_config detects lmstudio correctly
test_current_config_lmstudio() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:1234/v1"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "lmstudio" "$result"
}

# Test: get_current_config returns unknown for unrecognized config
test_current_config_unknown() {
    local content='{
  "env": {
    "ANTHROPIC_BASE_URL": "https://unknown.provider.com/api"
  }
}'

    local result
    result=$(with_test_settings "$content" "get_current_config")
    assert_equals "unknown" "$result"
}

# Test: get_friendly_name returns correct names
test_friendly_name() {
    assert_equals "Claude (Anthropic)" "$(get_friendly_name "claude")" || return 1
    assert_equals "Z.AI (GLM)" "$(get_friendly_name "zai")" || return 1
    assert_equals "DeepSeek" "$(get_friendly_name "deepseek")" || return 1
    assert_equals "Kimi (Moonshot)" "$(get_friendly_name "kimi")" || return 1
    assert_equals "Qwen Coder" "$(get_friendly_name "qwen")" || return 1
    assert_equals "OpenRouter" "$(get_friendly_name "openrouter")" || return 1
    assert_equals "Ollama (Local)" "$(get_friendly_name "ollama")" || return 1
    assert_equals "LM Studio (Local)" "$(get_friendly_name "lmstudio")" || return 1
    assert_equals "Unknown" "$(get_friendly_name "invalid")" || return 1
}

# Test: validate_model_name accepts valid model names
test_validate_model_name_valid() {
    validate_model_name "qwen3-coder:7b" > /dev/null || return 1
    validate_model_name "Qwen/Qwen2.5-Coder-32B-Instruct" > /dev/null || return 1
    validate_model_name "anthropic/claude-opus-4.6" > /dev/null || return 1
    validate_model_name "model_name-123" > /dev/null || return 1
    validate_model_name "" > /dev/null || return 1  # Empty is OK
}

# Test: validate_model_name rejects invalid characters
test_validate_model_name_invalid_chars() {
    # Should reject shell metacharacters
    if validate_model_name "model;rm -rf /" 2>/dev/null; then
        echo "Should reject semicolon"
        return 1
    fi
    if validate_model_name "model\$(whoami)" 2>/dev/null; then
        echo "Should reject command substitution"
        return 1
    fi
    if validate_model_name "model\`echo pwned\`" 2>/dev/null; then
        echo "Should reject backtick command substitution"
        return 1
    fi
    if validate_model_name "model|cat /etc/passwd" 2>/dev/null; then
        echo "Should reject pipe"
        return 1
    fi
    if validate_model_name "model && echo pwned" 2>/dev/null; then
        echo "Should reject &&"
        return 1
    fi
    if validate_model_name "model < /etc/passwd" 2>/dev/null; then
        echo "Should reject <"
        return 1
    fi
}

# Test: validate_model_name rejects path traversal
test_validate_model_name_path_traversal() {
    if validate_model_name "../../../etc/passwd" 2>/dev/null; then
        echo "Should reject path traversal"
        return 1
    fi
    if validate_model_name "..\..\..\windows\system32" 2>/dev/null; then
        echo "Should reject Windows path traversal"
        return 1
    fi
    if validate_model_name "./../../etc/hosts" 2>/dev/null; then
        echo "Should reject ./ path traversal"
        return 1
    fi
}

# Test: validate_model_name rejects oversized model names
test_validate_model_name_too_long() {
    local long_model
    long_model=$(printf 'a%.0s' {1..256})
    if validate_model_name "$long_model" 2>/dev/null; then
        echo "Should reject oversized model name"
        return 1
    fi
}

# Test: validate_model_name accepts edge case valid names
test_validate_model_name_edge_cases() {
    validate_model_name "a" > /dev/null || return 1  # Single char
    validate_model_name "A" > /dev/null || return 1
    validate_model_name "0" > /dev/null || return 1
    validate_model_name "model-123_456/789.0" > /dev/null || return 1  # All allowed chars
}

# Test: validate_key fails when env var is not set
test_validate_key_missing() {
    unset NONEXISTENT_KEY
    ! validate_key "NONEXISTENT_KEY" 2>/dev/null
}

# Test: validate_key passes when env var is set
test_validate_key_present() {
    export TEST_KEY="test-value"
    validate_key "TEST_KEY" > /dev/null
    local result=$?
    unset TEST_KEY
    return $result
}
