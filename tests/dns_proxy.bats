#!/usr/bin/env bats

load 'helpers/common'

@test "dns_proxy: no proxies enabled -> [OK]" {
  run_check dns_proxy
  [ "$status" -eq 0 ]
  assert_output_contains "[OK]"
  assert_output_contains "No system proxies enabled"
}

@test "dns_proxy: SOCKS proxy warning includes complete disable command" {
  MOCK_NETWORKSETUP=socks_enabled run_check dns_proxy
  [ "$status" -eq 0 ]
  assert_output_contains "[!]"
  assert_output_contains "SOCKS proxy enabled on Wi-Fi: 127.0.0.1:1080"
  assert_output_contains "networksetup -setsocksfirewallproxystate \"Wi-Fi\" off"
}
