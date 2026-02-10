#!/bin/bash
# Unit tests for model mapping functions
# Tests get_*_models() functions for all providers

# Test: Anthropic model mapping returns correct models
test_anthropic_model_mapping() {
    local result
    result=$(get_anthropic_models)

    assert_contains "$result" "opus:claude-opus-4-6" || return 1
    assert_contains "$result" "sonnet:claude-sonnet-4-5-20250929" || return 1
    assert_contains "$result" "haiku:claude-haiku-4-20250920" || return 1
}

# Test: Z.AI model mapping returns correct models
test_zai_model_mapping() {
    local result
    result=$(get_zai_models)

    assert_contains "$result" "opus:glm-4.7" || return 1
    assert_contains "$result" "sonnet:glm-4.7" || return 1
    assert_contains "$result" "haiku:glm-4.5-flash" || return 1
}

# Test: DeepSeek model mapping returns correct models
test_deepseek_model_mapping() {
    local result
    result=$(get_deepseek_models)

    assert_contains "$result" "opus:deepseek-chat" || return 1
    assert_contains "$result" "sonnet:deepseek-chat" || return 1
    assert_contains "$result" "haiku:deepseek-chat" || return 1
}

# Test: Kimi model mapping returns correct models
test_kimi_model_mapping() {
    local result
    result=$(get_kimi_models)

    assert_contains "$result" "opus:moonshot-v1-128k" || return 1
    assert_contains "$result" "sonnet:moonshot-v1-32k" || return 1
    assert_contains "$result" "haiku:moonshot-v1-8k" || return 1
}

# Test: Qwen model mapping returns correct models
test_qwen_model_mapping() {
    local result
    result=$(get_qwen_models)

    assert_contains "$result" "opus:Qwen/Qwen2.5-Coder-32B-Instruct" || return 1
    assert_contains "$result" "sonnet:Qwen/Qwen2.5-Coder-14B-Instruct" || return 1
    assert_contains "$result" "haiku:Qwen/Qwen2.5-Coder-7B-Instruct" || return 1
}

# Test: OpenRouter model mapping uses default when no env var set
test_openrouter_default_model() {
    # Unset to test default behavior
    unset OPENROUTER_DEFAULT_MODEL

    local result
    result=$(get_openrouter_models)

    assert_contains "$result" "opus:anthropic/claude-opus-4.6" || return 1
}

# Test: OpenRouter model mapping respects env var
test_openrouter_custom_model() {
    export OPENROUTER_DEFAULT_MODEL="custom/model-name"

    local result
    result=$(get_openrouter_models)

    assert_contains "$result" "opus:custom/model-name" || return 1

    unset OPENROUTER_DEFAULT_MODEL
}

# Test: OpenRouter all tiers use same model
test_openrouter_same_model_all_tiers() {
    export OPENROUTER_DEFAULT_MODEL="test/model"

    local result
    result=$(get_openrouter_models)

    # Extract model names
    local opus_model sonnet_model haiku_model
    opus_model=$(echo "$result" | grep -o 'opus:[^ ]*' | cut -d: -f2)
    sonnet_model=$(echo "$result" | grep -o 'sonnet:[^ ]*' | cut -d: -f2)
    haiku_model=$(echo "$result" | grep -o 'haiku:[^ ]*' | cut -d: -f2)

    assert_equals "$opus_model" "$sonnet_model" "Opus and Sonnet models should match" || return 1
    assert_equals "$sonnet_model" "$haiku_model" "Sonnet and Haiku models should match" || return 1

    unset OPENROUTER_DEFAULT_MODEL
}

# Test: LM Studio model mapping returns empty models
test_lmstudio_model_mapping() {
    local result
    result=$(get_lmstudio_models)

    assert_contains "$result" "opus:" || return 1
    assert_contains "$result" "sonnet:" || return 1
    assert_contains "$result" "haiku:" || return 1
}

# Test: Model mapping output has correct format (key:value pairs)
test_model_mapping_format() {
    local result
    result=$(get_anthropic_models)

    # Should contain exactly 3 space-separated key:value pairs
    local count
    count=$(echo "$result" | grep -o '[a-z]*:[a-z0-9.-]*' | wc -l)
    assert_equals "3" "$count" "Should have 3 model mappings" || return 1
}

# Test: All provider model functions are callable
test_all_provider_functions_callable() {
    local providers=("anthropic" "zai" "deepseek" "kimi" "qwen" "openrouter" "lmstudio")

    for provider in "${providers[@]}"; do
        local func="get_${provider}_models"
        if declare -f "$func" > /dev/null; then
            # Function exists, try to call it
            "$func" > /dev/null || return 1
        else
            echo -e "${RED}✗${NC} Function $func not found"
            return 1
        fi
    done
}
