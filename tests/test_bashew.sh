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

root_folder=$(cd .. && pwd) # tests/.. is root folder
root_script="$root_folder/bashew.sh" # take largest .sh (in case there are smaller helper .sh scripts present)
template_folder=$(cd ../template && pwd) # tests/../template is root folder

test_bashew2_create_normal_script() {
  # script without parameters should give usage info
  temp_folder="./test.$RANDOM"
  current_folder=$(pwd)
  mkdir "$temp_folder"
  cd "$temp_folder" || exit
  assert_status_code 0 "\"$root_script\" -q -f -n test_script.sh script"
  assert "test -e test_script.sh"
  cd "$current_folder" || exit
  rm -fr "$temp_folder"
}

test_bashew3_create_short_script() {
  # script without parameters should give usage info
  temp_folder="./test.$RANDOM"
  current_folder=$(pwd)
  mkdir "$temp_folder"
  cd "$temp_folder" || exit
  assert_status_code 0 "\"$root_script\" -q -f -n small_script.sh -m small script"
  assert "test -e small_script.sh"
  cd "$current_folder" || exit
  rm -fr "$temp_folder"
}

test_normal1_show_option_verbose() {
  # script without parameters should give usage info
  assert_equals 1 "$("$template_folder/normal.sh"  2>&1 | grep -c "verbose")"
}

test_small1_show_option_verbose() {
  # script without parameters should give usage info
  assert_equals 1 "$("$template_folder/small.sh" -h 2>&1 | grep -c "verbose")"
}

test_normal2_action_check_works() {
  # script without parameters should give usage info
  assert_equals 1 "$("$template_folder/normal.sh" check 2>&1 | grep -c "verbose=")"
  assert_equals 1 "$("$template_folder/normal.sh" check 2>&1 | grep -c "log_dir=")"
}

