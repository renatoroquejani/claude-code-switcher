# Test Suite for Claude Code Switcher

This directory contains the comprehensive test framework for `claude-switch`.

## Structure

```
tests/
├── test-suite.sh              # Main test runner
├── unit/                      # Unit tests
│   ├── test-model-mapping.sh  # Model mapping function tests
│   └── test-validation.sh     # Validation function tests
├── integration/               # Integration tests
│   └── test-provider-switch.sh # Full provider switching tests
└── fixtures/                  # Test fixtures and temp files
```

## Running Tests

### Run all tests:
```bash
./tests/test-suite.sh
```

### Run only unit tests:
```bash
./tests/test-suite.sh unit
```

### Run only integration tests:
```bash
./tests/test-suite.sh "" integration
```

### Run a specific test file:
```bash
# Source the test suite and run specific file
source tests/test-suite.sh
run_test_file tests/unit/test-model-mapping.sh
```

## Test Categories

### Unit Tests (`unit/`)
Test individual functions in isolation:
- **Model Mapping Tests**: Verify `get_*_models()` functions return correct models
- **Validation Tests**: Verify `validate_model_name()`, `get_current_config()`, etc.

### Integration Tests (`integration/`)
Test full workflows:
- **Provider Switch Tests**: Verify `apply_config()` correctly modifies settings.json

## Writing New Tests

### Adding a unit test:

1. Create a new file in `tests/unit/test-*.sh`
2. Define test functions starting with `test_`:
```bash
test_my_feature() {
    local result
    result=$(my_function "input")
    assert_equals "expected" "$result" || return 1
}
```

### Adding an integration test:

1. Create a new file in `tests/integration/test-*.sh`
2. Use `setup_test_settings()` to create a fresh settings file
3. Use `assert_json_key()` to verify JSON modifications

### Available assertions:

- `assert_equals <expected> <actual> [message]`
- `assert_contains <haystack> <needle> [message]`
- `assert_matches <string> <pattern> [message]`
- `assert_file_exists <file> [message]`
- `assert_json_key <file> <key> <expected> [message]`
- `assert_succeeds <command> [message]`
- `assert_fails <command> [message]`

### Skipping tests:

```bash
if ! command -v ollama &> /dev/null; then
    skip_test "test_ollama_feature" "Ollama not installed"
fi
```

## Test Fixtures

Test fixtures are auto-generated in `tests/fixtures/`:
- `test-settings.json` - Mock Claude settings file
- `backups/` - Mock backup directory

## CI/CD Integration

For CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run tests
  run: ./tests/test-suite.sh

# With coverage
- name: Run tests with coverage
  run: |
    ./tests/test-suite.sh
    # Add coverage reporting here
```

## Dependencies

- `bash` 4.0+
- `jq` - JSON processor for assertions
- `shellcheck` (optional) - Shell script linter

Run shellcheck on test files:
```bash
shellcheck tests/test-suite.sh
shellcheck tests/unit/*.sh
shellcheck tests/integration/*.sh
```
