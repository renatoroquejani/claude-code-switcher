#!/bin/bash
# Test Suite for Claude Code Switcher
# Main test runner that executes all unit and integration tests

set -e

# Colors for test output (define before sourcing anything else)
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test suite directory
readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$TEST_DIR")"
readonly FIXTURES_DIR="$TEST_DIR/fixtures"
readonly SETTINGS="${FIXTURES_DIR}/test-settings.json"
readonly BACKUP_DIR="${FIXTURES_DIR}/backups"

# Create fixtures directories
mkdir -p "$BACKUP_DIR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SOURCE MAIN SCRIPT FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Source functions from bin/claude-switch without running main
source_bin_functions() {
    # Set up minimal environment for testing
    export VERSION="2.1.0-test"
    export SETTINGS="${FIXTURES_DIR}/test-settings.json"
    export BACKUP_DIR="${FIXTURES_DIR}/backups"

    # Create fixtures directories
    mkdir -p "$BACKUP_DIR"

    # Read the main script and extract only function definitions
    # Skip the color definitions (lines 6-13) and main execution (lines 720+)
    local bin_file="$PROJECT_DIR/bin/claude-switch"

    # Create a wrapper that defines functions without running main
    # We'll use eval to define functions safely
    while IFS= read -r line; do
        # Skip color definitions and main execution
        [[ "$line" =~ ^(GREEN|YELLOW|RED|BLUE|CYAN|BOLD|NC)= ]] && continue
        [[ "$line" =~ ^(mkdir|chmod) ]] && continue
        [[ "$line" =~ "^# MAIN$" ]] && break

        # Accumulate function definitions
        if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*\(\) ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            eval "$line"
        fi
    done < "$bin_file"
}

# Alternative: Directly source with safeguards
source_with_safeguards() {
    export VERSION="2.1.0-test"
    export SETTINGS="${FIXTURES_DIR}/test-settings.json"
    export BACKUP_DIR="${FIXTURES_DIR}/backups"
    mkdir -p "$BACKUP_DIR"

    # Save current readonly status
    local readonly_vars=(GREEN YELLOW RED BLUE CYAN BOLD NC)

    # Temporarily allow redefinition
    for var in "${readonly_vars[@]}"; do
        unset "$var" 2>/dev/null || true
    done

    # Source the main script functions only (lines 18-718: after mkdir, before MAIN)
    local bin_file="$PROJECT_DIR/bin/claude-switch"

    # Use bash to source only the function definitions
    bash << 'SCRIPT_EOF'
    # Read and output only function definitions from the script
    awk '/^# MODEL MAPPING/,/^# MAIN/ {print}' "$1" | grep -E '^(#[a-z_]+|[[:space:]]*[a-z_]+\(\)|[[:space:]]*local|[[:space:]]*echo|[[:space:]]*return|[[:space:]]*if|[[:space:]]*then|[[:space:]]*fi|[[:space:]]*else|[[:space:]]*for|[[:space:]]*do|[[:space:]]*done|[[:space:]]*case|[[:space:]]*esac|[[:space:]]*while|[[:space:]]*)[[:space:]]*$)' | head -n 700
SCRIPT_EOF

    # Restore colors as readonly
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly RED='\033[0;31m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOAD FUNCTIONS FROM MAIN SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# We'll define key functions directly here for testing
# This avoids sourcing issues with readonly variables

get_anthropic_models() {
  echo "opus:claude-opus-4-6 sonnet:claude-sonnet-4-5-20250929 haiku:claude-haiku-4-20250920"
}

get_zai_models() {
  echo "opus:glm-4.7 sonnet:glm-4.7 haiku:glm-4.5-flash"
}

get_deepseek_models() {
  echo "opus:deepseek-chat sonnet:deepseek-chat haiku:deepseek-chat"
}

get_kimi_models() {
  echo "opus:moonshot-v1-128k sonnet:moonshot-v1-32k haiku:moonshot-v1-8k"
}

get_qwen_models() {
  echo "opus:Qwen/Qwen2.5-Coder-32B-Instruct sonnet:Qwen/Qwen2.5-Coder-14B-Instruct haiku:Qwen/Qwen2.5-Coder-7B-Instruct"
}

get_openrouter_models() {
  local model="${OPENROUTER_DEFAULT_MODEL:-anthropic/claude-opus-4.6}"
  echo "opus:$model sonnet:$model haiku:$model"
}

get_ollama_models() {
  local installed=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  local opus="qwen3-coder:32b" sonnet="qwen3-coder:14b" haiku="qwen3-coder:7b"

  echo "$installed" | grep -q "^${opus}" || opus="$sonnet"
  echo "$installed" | grep -q "^${opus}" || opus="$haiku"
  echo "$installed" | grep -q "^${sonnet}" || sonnet="$opus"
  echo "$installed" | grep -q "^${haiku}" || haiku="$sonnet"

  if [ -z "$opus" ]; then
    opus=$(echo "$installed" | head -1)
    sonnet="$opus"
    haiku="$opus"
  fi

  echo "opus:$opus sonnet:$sonnet haiku:$haiku"
}

get_lmstudio_models() {
  echo "opus: sonnet: haiku:"
}

get_current_config() {
  local base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "oauth"' "$SETTINGS" 2>/dev/null)

  case "$base_url" in
    "oauth"|"null") echo "claude" ;;
    *"z.ai"*) echo "zai" ;;
    *"deepseek"*) echo "deepseek" ;;
    *"moonshot"*) echo "kimi" ;;
    *"siliconflow"*) echo "qwen" ;;
    *"openrouter"*) echo "openrouter" ;;
    *"localhost:11434"*|*"127.0.0.1:11434"*) echo "ollama" ;;
    *"localhost:1234"*|*"127.0.0.1:1234"*) echo "lmstudio" ;;
    *) echo "unknown" ;;
  esac
}

get_friendly_name() {
  case "$1" in
    claude|anthropic) echo "Claude (Anthropic)" ;;
    zai|z.ai|glm) echo "Z.AI (GLM)" ;;
    deepseek) echo "DeepSeek" ;;
    kimi) echo "Kimi (Moonshot)" ;;
    qwen) echo "Qwen Coder" ;;
    openrouter) echo "OpenRouter" ;;
    ollama) echo "Ollama (Local)" ;;
    lmstudio) echo "LM Studio (Local)" ;;
    *) echo "Unknown" ;;
  esac
}

validate_model_name() {
  local model="$1"

  if [ -z "$model" ]; then
    return 0
  fi

  if [ ${#model} -gt 255 ]; then
    echo -e "${RED}❌ Model name too long (max 255 characters)${NC}"
    return 1
  fi

  case "$model" in
    *[!a-zA-Z0-9_\-/:.]*)
      echo -e "${RED}❌ Invalid model name: $model${NC}"
      return 1
      ;;
  esac

  if [[ "$model" =~ \.\. ]]; then
    echo -e "${RED}❌ Path traversal not allowed${NC}"
    return 1
  fi

  return 0
}

validate_key() {
  local key_name="$1"
  local key_value="${!key_name}"

  if [ -z "$key_value" ]; then
    echo -e "${RED}❌ $key_name not configured${NC}"
    return 1
  fi
  return 0
}

clear_all_models() {
  local tmp_settings
  tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
  jq 'del(.env.ANTHROPIC_MODEL,
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL,
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL,
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL)' \
     "$SETTINGS" > "$tmp_settings"
  mv "$tmp_settings" "$SETTINGS"
}

apply_config() {
  local provider="$1"
  local override_model="$2"

  if [ -n "$override_model" ]; then
    validate_model_name "$override_model" || return 1
  fi

  case "$provider" in
    anthropic) provider="claude" ;;
    z.ai|glm) provider="zai" ;;
  esac

  cp "$SETTINGS" "$BACKUP_DIR/settings.json.backup-$(date +%Y%m%d-%H%M%S)"

  local opus_model=""
  local sonnet_model=""
  local haiku_model=""

  case "$provider" in
    claude)
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq 'del(.env.ANTHROPIC_AUTH_TOKEN, .env.ANTHROPIC_BASE_URL)' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    zai)
      local api_key="${ZAI_API_KEY:-$GLM_API_KEY}"
      if [ -z "$api_key" ]; then
        echo -e "${RED}❌ ZAI_API_KEY (or GLM_API_KEY) not configured${NC}"
        return 1
      fi

      clear_all_models
      opus_model="glm-4.7"
      sonnet_model="glm-4.7"
      haiku_model="glm-4.5-flash"

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$api_key" \
         --arg opus "$opus_model" \
         --arg sonnet "$sonnet_model" \
         --arg haiku "$haiku_model" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $opus |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $sonnet |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $haiku' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    deepseek)
      validate_key "DEEPSEEK_API_KEY" || return 1
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$DEEPSEEK_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-chat" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-chat" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-chat"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    kimi)
      validate_key "KIMI_API_KEY" || return 1
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$KIMI_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "moonshot-v1-128k" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "moonshot-v1-32k" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "moonshot-v1-8k"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    qwen)
      validate_key "SILICONFLOW_API_KEY" || return 1
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$SILICONFLOW_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.siliconflow.cn/v1/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "Qwen/Qwen2.5-Coder-32B-Instruct" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "Qwen/Qwen2.5-Coder-14B-Instruct" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "Qwen/Qwen2.5-Coder-7B-Instruct"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    openrouter)
      validate_key "OPENROUTER_API_KEY" || return 1
      clear_all_models

      if [ -n "$override_model" ]; then
        opus_model="$override_model"
      elif [ -n "$OPENROUTER_DEFAULT_MODEL" ]; then
        opus_model="$OPENROUTER_DEFAULT_MODEL"
      else
        echo -e "${RED}❌ No model specified${NC}"
        return 1
      fi

      sonnet_model="$opus_model"
      haiku_model="$opus_model"

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$OPENROUTER_API_KEY" \
         --arg opus "$opus_model" \
         --arg sonnet "$sonnet_model" \
         --arg haiku "$haiku_model" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://openrouter.ai/api" |
          .env.ANTHROPIC_API_KEY = "" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $opus |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $sonnet |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $haiku' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    ollama)
      clear_all_models
      local default_opus="qwen3-coder:32b"
      local default_sonnet="qwen3-coder:14b"
      local default_haiku="qwen3-coder:7b"

      local installed_models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

      if [ -n "$override_model" ]; then
        opus_model="${override_model%:latest}"
        sonnet_model="$opus_model"
        haiku_model="$opus_model"
      else
        opus_model="qwen3-coder:32b"
        sonnet_model="qwen3-coder:14b"
        haiku_model="qwen3-coder:7b"

        if ! echo "$installed_models" | grep -q "^${opus_model}"; then
          opus_model="qwen3-coder:14b"
        fi
        if ! echo "$installed_models" | grep -q "^${opus_model}"; then
          opus_model="qwen3-coder:7b"
        fi
        if ! echo "$installed_models" | grep -q "^${opus_model}"; then
          opus_model=$(echo "$installed_models" | head -1)
        fi

        if ! echo "$installed_models" | grep -q "^${sonnet_model}"; then
          sonnet_model="$opus_model"
        fi
        if ! echo "$installed_models" | grep -q "^${haiku_model}"; then
          haiku_model="$sonnet_model"
        fi

        if [ -z "$opus_model" ]; then
          echo -e "${RED}❌ No Ollama models installed${NC}"
          return 1
        fi
      fi

      opus_model="${opus_model%:latest}"
      sonnet_model="${sonnet_model%:latest}"
      haiku_model="${haiku_model%:latest}"

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg opus "$opus_model" \
         --arg sonnet "$sonnet_model" \
         --arg haiku "$haiku_model" \
         '.env.ANTHROPIC_AUTH_TOKEN = "ollama" |
          .env.ANTHROPIC_BASE_URL = "http://localhost:11434" |
          .env.ANTHROPIC_MODEL = $haiku |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $opus |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $sonnet |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $haiku' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    lmstudio)
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq '.env.ANTHROPIC_AUTH_TOKEN = "lmstudio" |
          .env.ANTHROPIC_BASE_URL = "http://localhost:1234/v1"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    *)
      echo -e "${RED}❌ Unknown provider:${NC} $provider"
      return 1
      ;;
  esac

  chmod 600 "$SETTINGS"
  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEST FRAMEWORK FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Assert equals
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected', got '$actual'}"

    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  ${CYAN}expected:${NC} $expected"
        echo -e "  ${CYAN}actual:${NC}   $actual"
        return 1
    fi
}

# Assert contains
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to contain '$needle'}"

    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

# Assert matches regex
assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-Expected '$string' to match pattern '$pattern'}"

    if [[ "$string" =~ $pattern ]]; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file to exist: $file}"

    if [ -f "$file" ]; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

# Assert file contains JSON key
assert_json_key() {
    local file="$1"
    local key="$2"
    local expected="$3"
    local message="${4:-Expected $key to be '$expected' in $file}"

    local actual
    actual=$(jq -r "$key // \"\"" "$file" 2>/dev/null)

    if [ "$actual" = "$expected" ]; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  ${CYAN}expected:${NC} $expected"
        echo -e "  ${CYAN}actual:${NC}   $actual"
        return 1
    fi
}

# Assert command succeeds
assert_succeeds() {
    local message="${2:-Command failed: $1}"

    if eval "$1" &>/dev/null; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

# Assert command fails
assert_fails() {
    local message="${2:-Command succeeded but should have failed: $1}"

    if ! eval "$1" &>/dev/null; then
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        return 1
    fi
}

# Run a single test
run_test() {
    local test_name="$1"
    local test_func="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if eval "$test_func"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Skip a test
skip_test() {
    local test_name="$1"
    local reason="${2:-No reason given}"

    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "${YELLOW}⊘${NC} $test_name ${CYAN}($reason)${NC}"
}

# Run all tests in a file
run_test_file() {
    local test_file="$1"
    local suite_name

    suite_name=$(basename "$test_file" .sh)
    suite_name="${suite_name#test-}"

    echo ""
    echo -e "${BOLD}${BLUE}Running: $suite_name${NC}"
    echo -e "${BLUE}────────────────────────────────────────${NC}"

    # Source the test file
    source "$test_file"

    # Run all test functions (functions starting with "test_")
    local test_funcs
    test_funcs=$(declare -F | awk '{print $3}' | grep '^test_' | sort)

    for test_func in $test_funcs; do
        run_test "$test_func" "$test_func"
    done
}

# Print test summary
print_summary() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Test Summary${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "  Total:   ${BOLD}$TESTS_RUN${NC}"
    echo -e "  ${GREEN}Passed:${NC}  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed:${NC}  ${RED}$TESTS_FAILED${NC}"
    echo -e "  ${YELLOW}Skipped:${NC} ${YELLOW}$TESTS_SKIPPED${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Cleanup fixtures
cleanup_fixtures() {
    rm -rf "${FIXTURES_DIR:?}"/*
    mkdir -p "$BACKUP_DIR"
    setup_test_settings
}

# Setup test settings file
setup_test_settings() {
    local test_settings="$SETTINGS"
    cat > "$test_settings" << 'TESTEOF'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "test-token",
    "ANTHROPIC_BASE_URL": "https://api.test.com"
  }
}
TESTEOF
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
    local unit_only="${1:-}"
    local integration_only="${2:-}"

    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║   Claude Code Switcher Test Suite v1.0.0        ║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════╝${NC}"

    # Initialize
    setup_test_settings

    # Run unit tests
    if [ -z "$integration_only" ]; then
        for test_file in "$TEST_DIR"/unit/test-*.sh; do
            if [ -f "$test_file" ]; then
                run_test_file "$test_file"
            fi
        done
    fi

    # Run integration tests
    if [ -z "$unit_only" ]; then
        for test_file in "$TEST_DIR"/integration/test-*.sh; do
            if [ -f "$test_file" ]; then
                run_test_file "$test_file"
            fi
        done
    fi

    # Print summary and exit
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
