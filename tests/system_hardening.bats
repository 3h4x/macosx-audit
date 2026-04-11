#!/usr/bin/env bats

load 'helpers/common'

@test "system_hardening: SIP enabled → [OK]" {
  MOCK_CSRUTIL=enabled run_check system_hardening
  assert_output_contains "[OK]"
  assert_output_contains "System Integrity Protection"
}

@test "system_hardening: SIP disabled → [!!]" {
  MOCK_CSRUTIL=disabled run_check system_hardening
  assert_output_contains "[!!]"
  assert_output_contains "SIP is DISABLED"
}

@test "system_hardening: Gatekeeper enabled → [OK]" {
  MOCK_SPCTL=enabled run_check system_hardening
  assert_output_contains "Gatekeeper enabled"
}

@test "system_hardening: Gatekeeper disabled → [!]" {
  MOCK_SPCTL=disabled run_check system_hardening
  assert_output_contains "[!]"
  assert_output_contains "Gatekeeper disabled"
}

@test "system_hardening: FileVault on → [OK]" {
  MOCK_FDESETUP=on run_check system_hardening
  assert_output_contains "FileVault disk encryption enabled"
}

@test "system_hardening: FileVault off → [!]" {
  MOCK_FDESETUP=off run_check system_hardening
  assert_output_contains "[!]"
  assert_output_contains "FileVault OFF"
}
