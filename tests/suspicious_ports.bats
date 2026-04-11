#!/usr/bin/env bats

load 'helpers/common'

@test "suspicious_ports: clean lsof → [OK]" {
  MOCK_LSOF=clean run_check suspicious_ports
  assert_output_contains "[OK]"
  assert_output_contains "No listening on known suspicious ports"
}

# Detection: port 4444 in lsof output → [!!] critical
@test "suspicious_ports: port 4444 listening → [!!]" {
  MOCK_LSOF=suspicious_port run_check suspicious_ports
  assert_output_contains "[!!]"
  assert_output_contains "4444"
}
