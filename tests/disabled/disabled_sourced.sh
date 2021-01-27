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

test_unit_function_hash() {
  # test function hash
  assert_equals d8e8fc "$(echo test | hash)"
}

test_unit_function_lower_case() {
  # script without parameters should give usage info
  assert_equals "abc-xyz" "$(lower_case "ABC-XYZ")"
}

test_unit_function_slugify() {
  # script without parameters should give usage info
  assert_equals "peter-forret-ir" "$(slugify "(Peter Forret, Ir.)")"
}

test_unit_function_wordcount() {
  # script without parameters should give usage info
  assert_equals 4 "$(echo "one two three four" | count_words)"
}

test_unit_function_recursive_readlink() {
  [[ -f "$HOME/.basher/cellar/bin/bashew" ]] && assert_equals "$HOME/.basher/cellar/packages/pforret/bashew/bashew.sh" "$(recursive_readlink "$HOME/.basher/cellar/bin/bashew")"
}

test_unit_var_script_install_path() {
  # script without parameters should give usage info
  # shellcheck disable=SC2154
  assert_equals "../template/normal.sh" "$script_install_path"
}
