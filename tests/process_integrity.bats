#!/usr/bin/env bats

load 'helpers/common'

setup() {
  # Create a real temp file so [[ -f "$binary" ]] passes in the check
  TMPBINARY="$(mktemp /tmp/test_audit_binary_XXXXX)"
  chmod +x "$TMPBINARY"
  export TMPBINARY
}

teardown() {
  rm -f "$TMPBINARY"
}

@test "process_integrity: all signed → [OK]" {
  MOCK_PS=signed MOCK_CODESIGN=valid run_check process_integrity
  assert_output_contains "[OK]"
  assert_output_contains "All running processes have valid signatures"
}

# Detection: unsigned binary in process list → [!] warning
@test "process_integrity: unsigned process → [!]" {
  MOCK_PS=unsigned \
  MOCK_PS_BINARY="$TMPBINARY" \
  MOCK_CODESIGN=unsigned \
  run_check process_integrity
  assert_output_contains "[!]"
  assert_output_contains "Unsigned/invalid process"
}
