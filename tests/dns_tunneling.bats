#!/usr/bin/env bats

load 'helpers/common'

# Regression: zero DNS queries must not cause arithmetic error (grep -c || echo "0" bug)
@test "dns_tunneling: zero queries → no crash, [OK]" {
  MOCK_LSOF_DNS=empty MOCK_LOG=empty run_check dns_tunneling
  [ "$status" -eq 0 ]
  assert_output_contains "[OK]"
  assert_output_not_contains "arithmetic syntax error"
}

@test "dns_tunneling: zero queries → reports 0 queries, no warning" {
  MOCK_LSOF_DNS=empty MOCK_LOG=empty run_check dns_tunneling
  assert_output_contains "queries"
  assert_output_not_contains "[!]"
}

@test "dns_tunneling: log stderr failure -> stderr is not counted as DNS logs" {
  MOCK_LSOF_DNS=empty MOCK_LOG=stderr run_check dns_tunneling
  [ "$status" -eq 0 ]
  assert_output_contains "[OK]"
  assert_output_not_contains "log: failed to collect entries"
  assert_output_not_contains "[!]"
}

# Detection: high query volume triggers warning
@test "dns_tunneling: >500 DNS queries → [!] warning" {
  MOCK_LSOF_DNS=empty MOCK_LOG=high_volume run_check dns_tunneling
  assert_output_contains "[!]"
  assert_output_contains "High DNS query volume"
}
