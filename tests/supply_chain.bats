#!/usr/bin/env bats

load 'helpers/common'

@test "supply_chain: default brew taps → no warning" {
  MOCK_BREW_TAPS=default run_check supply_chain
  assert_output_not_contains "Non-default brew tap"
}

# Detection: non-default brew tap → [!] warning
@test "supply_chain: suspicious brew tap → [!]" {
  MOCK_BREW_TAPS=suspicious run_check supply_chain
  assert_output_contains "[!]"
  assert_output_contains "Non-default brew tap"
  assert_output_contains "somehacker/evil-tools"
}

@test "supply_chain: npm globals present → informational, no crash" {
  MOCK_NPM_GLOBALS=populated run_check supply_chain
  [ "$status" -eq 0 ]
  assert_output_contains "npm global packages"
}
