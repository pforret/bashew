# test functions should start with test_

root_folder=$(cd .. && pwd) # tests/.. is root folder
root_script=$(ls -S "$root_folder"/*.sh | head -1) # take largest .sh (in case there are smaller helper .sh scripts present)

test_should_show_option_verbose() {
  # script without parameters should give usage info
  assert_equals 1 $("$root_script" 2>&1 | grep -c "verbose")
}
