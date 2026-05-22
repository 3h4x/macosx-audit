#!/usr/bin/env bats

load 'helpers/common'

@test "extensions: systemextensionsctl error does not abort the check" {
  MOCK_SYSTEMEXTENSIONSCTL=error run_check extensions
  [ "$status" -eq 0 ]
  assert_output_contains "systemextensionsctl returned error (69) — skipping system extension inventory"
  assert_output_contains "OSSystemExtensionErrorDomain"
}

@test "extensions: zero system extensions -> [OK]" {
  MOCK_SYSTEMEXTENSIONSCTL=zero run_check extensions
  [ "$status" -eq 0 ]
  assert_output_contains "[OK]"
  assert_output_contains "No system extensions"
}

@test "extensions: installed system extensions are listed" {
  MOCK_SYSTEMEXTENSIONSCTL=present run_check extensions
  [ "$status" -eq 0 ]
  assert_output_contains "System extensions:"
  assert_output_contains "bundleID: com.example.driver"
}
