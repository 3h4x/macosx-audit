#!/usr/bin/env bats

load 'helpers/common'

@test "screensaver: password required → [OK]" {
  MOCK_SCREENSAVER_ASK_PW=1 \
  MOCK_SCREENSAVER_PW_DELAY=0 \
  MOCK_SCREENSAVER_IDLE_TIME=300 \
  run_check screensaver
  assert_output_contains "[OK]"
  assert_output_contains "Screensaver requires password"
}

@test "screensaver: password not required → [!!]" {
  MOCK_SCREENSAVER_ASK_PW=0 \
  MOCK_SCREENSAVER_IDLE_TIME=300 \
  run_check screensaver
  assert_output_contains "[!!]"
  assert_output_contains "does NOT require password"
}

@test "screensaver: password delay set → [!]" {
  MOCK_SCREENSAVER_ASK_PW=1 \
  MOCK_SCREENSAVER_PW_DELAY=30 \
  MOCK_SCREENSAVER_IDLE_TIME=300 \
  run_check screensaver
  assert_output_contains "[!]"
  assert_output_contains "password delay"
}

@test "screensaver: idle time too long → [!]" {
  MOCK_SCREENSAVER_ASK_PW=1 \
  MOCK_SCREENSAVER_PW_DELAY=0 \
  MOCK_SCREENSAVER_IDLE_TIME=600 \
  run_check screensaver
  assert_output_contains "[!]"
  assert_output_contains "consider reducing"
}
