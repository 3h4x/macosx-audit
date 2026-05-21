#!/usr/bin/env bats

load 'helpers/common'

@test "time_sync: timed running with low drift -> [OK]" {
  MOCK_PGREP=timed MOCK_SNTP=ok run_check time_sync
  [ "$status" -eq 0 ]
  assert_output_contains "timed running (PID 123)"
  assert_output_contains "Time offset from Apple NTP: +0.4s"
  assert_output_contains "[OK]"
}

@test "time_sync: hanging sntp -> warning without external timeout dependency" {
  MOCK_PGREP=timed MOCK_SNTP=hang run_check time_sync
  [ "$status" -eq 0 ]
  assert_output_contains "Could not reach time.apple.com to measure offset"
}

@test "time_sync: sntp stderr failure -> warning without parsing stderr as offset" {
  MOCK_PGREP=timed MOCK_SNTP=stderr run_check time_sync
  [ "$status" -eq 0 ]
  assert_output_contains "Could not reach time.apple.com to measure offset"
  assert_output_not_contains "Time offset from Apple NTP: sntp:"
}
