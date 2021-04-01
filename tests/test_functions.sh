#!/usr/bin/env bash
# test functions should start with test_
# using https://github.com/pgrange/bash_unit
#  fail
#  assert
#  assert "test -e /tmp/the_file"
#  assert_fails "grep this /tmp/the_file" "should not write 'this' in /tmp/the_file"
#  assert_status_code 25 code
#  assert_equals "a string" "another string" "a string should be another string"
#  assert_not_equals "a string" "a string" "a string should be different from another string"
#  fake ps echo hello world

setup_suite(){
  # shellcheck disable=SC1091
  source "../template/normal.sh"
}

test_lower_case() {
  assert_equals "james bond jr." "$(lower_case "James Bond Jr.")"
  assert_equals "été de garçon" "$(lower_case "Été de Garçon")"
}

test_upper_case() {
  assert_equals "JAMES BOND JR." "$(upper_case "James Bond Jr.")"
  assert_equals "ÉTÉ DE GARÇON" "$(upper_case "Été de Garçon")"
}

test_title_case(){
  assert_equals "JamesBondJr" "$(title_case "James Bond Jr.")"
  assert_equals "It_Was_Just_A_Question" "$(title_case "It was just a question?!" "_")"
}

test_slugify(){
  assert_equals "james-bond-jr" "$(slugify "James Bond Jr.")"
  assert_equals "il_etait_une_fois" "$(slugify "Il était une fois ..." "_")"
  assert_equals "but-is-it-jack-or-jill" "$(slugify "but... is it Jack, or Jill???")"
  assert_equals "internationalisation" "$(slugify "ïñtèrnätìønālíśâtïön")"
}