#!/usr/bin/env bash
# Shared helpers for all bats test files.
# Load with: load 'helpers/common'

AUDIT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/security-audit"
MOCK_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/mocks" && pwd)"
FIXTURE_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/fixtures" && pwd)"

# Run a single check via subprocess with mocks injected into PATH.
run_check() {
  local check="$1"; shift
  run env FIXTURE_DIR="$FIXTURE_DIR" PATH="$MOCK_DIR:$PATH" "$AUDIT" --check="$check"
}

# Assert output contains the given literal string.
assert_output_contains() {
  if ! echo "$output" | grep -qF "$1"; then
    echo "Expected output to contain: $1"
    echo "Actual output:"
    echo "$output"
    return 1
  fi
}

# Assert output does NOT contain the given literal string.
assert_output_not_contains() {
  if echo "$output" | grep -qF "$1"; then
    echo "Expected output NOT to contain: $1"
    echo "Actual output:"
    echo "$output"
    return 1
  fi
}
