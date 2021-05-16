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

root_folder="$(cd .. && pwd)" # tests/.. is root folder

setup_suite() {
  rnd_name="P$RANDOM"
  temp_folder="/tmp/bashew/$rnd_name"
  mkdir -p "$temp_folder"
  cp -r "$root_folder"/* "$temp_folder/"

  cd "$temp_folder" || exit
  git init &>/dev/null
  git add . &>/dev/null
  git commit -m "First commit" &>/dev/null
  ./bashew -q -n "$rnd_name" -f init
}

test_1_bashew_init() {
  assert "./bashew -q -n $rnd_name -f init"
}

test_2_script_exists() {

  assert "test -e ./$rnd_name.sh"
  assert "test -e ./$rnd_name"
}

test_3_script_executes() {
  assert "./$rnd_name"
  rm -fr "$temp_folder"
}

