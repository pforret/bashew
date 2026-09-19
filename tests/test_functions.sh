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

setup_suite() {
  # shellcheck disable=SC1091
  if [[ -f "../template/script.sh" ]]; then
    source "../template/script.sh"
    echo "# load bashew as library script"
  else
    echo "script [../template/script.sh] could not be found"
    exit 1
  fi

  export FORCE_COLOR=true
  export LC_ALL="en_US.UTF-8"
  export LANG="en_US.UTF-8"
  unicode=1
  [[ ! $(echo -e '\xe2\x82\xac') == '€' ]] && unicode=0
  [[ ! $(echo -e '\xE2\x98\xA0') == '☠' ]] && unicode=0
  [[ ! $(echo -e '\xc3\xa9') == 'é' ]] && unicode=0
  echo "# unicode = $unicode"
}

test_has_unicode() {
  # shellcheck disable=SC2154
  assert_equals 1 "$unicode"
}

test_lower() {
  assert_equals "james bond jr." "$(Str:lower "James Bond Jr.")"
  ((unicode)) && assert_equals "été de garçon" "$(Str:lower "Été de Garçon")"
}

test_upper() {
  assert_equals "JAMES BOND JR." "$(Str:upper "James Bond Jr.")"
  assert_equals "ÉTÉ DE GARÇON" "$(Str:upper "Été de Garçon")"
}

test_title() {
  assert_equals "JamesBondJr" "$(Str:title "James Bond Jr.")"
  assert_equals "It_Was_Just_A_Question" "$(Str:title "It was just a question?!" "_")"
}

test_slugify() {
  assert_equals "james-bond-jr" "$(Str:slugify "James Bond Jr.")"
  assert_equals "il_etait_une_fois" "$(Str:slugify "Il était une fois ..." "_")"
  assert_equals "but-is-it-jack-or-jill" "$(Str:slugify "but... is it Jack, or Jill???")"
  assert_equals "internationalisation" "$(Str:slugify "ïñtèrnätìønālíśâtïön")"
}

test_pick_empty_input_fails() {
  assert_fails "Tool:pick <<< ''"
  assert_equals "" "$(Tool:pick <<< '' || true)"
}

test_pick_with_fzf() {
  # fzf gets the options on stdin, we fake it to pick the 2nd line
  fake fzf 'sed -n 2p'
  assert_equals "green" "$(Tool:pick "Color?" <<< $'red\ngreen\nblue')"
  assert_equals "green" "$(printf 'red\ngreen\nblue\n' | Tool:pick)"
}

test_pick_with_fzf_cancelled() {
  fake fzf true
  assert_fails "Tool:pick <<< $'red\ngreen'"
}

test_pick_with_gum() {
  # gum gets the options as arguments (after --header=...), we fake it to pick the last one
  # PATH is emptied so a real fzf binary is not found and the gum branch is used
  # shellcheck disable=SC2016 # the fake code must be expanded when gum is called, not now
  fake gum 'echo "${FAKE_PARAMS[-1]}"'
  # shellcheck disable=SC2123 # emptying PATH (in a subshell) is intentional
  assert_equals "blue" "$(PATH=""; Tool:pick <<< $'red\ngreen\nblue')"
}

test_pick_with_other_option() {
  # without the 2nd parameter, no "other: ..." option is added; with it, it is added at the end
  local received
  received="$(mktemp)"
  # shellcheck disable=SC2016 # the fake code must be expanded when fzf is called, not now
  fake fzf 'tee "$received" | head -1'
  assert_equals "red" "$(Tool:pick "Color?" <<< $'red\ngreen\nblue')"
  assert_equals "blue" "$(tail -1 "$received")"
  assert_equals "red" "$(Tool:pick "Color?" 1 <<< $'red\ngreen\nblue')"
  assert_equals "other: ..." "$(tail -1 "$received")"
  assert_equals 4 "$(wc -l < "$received" | tr -d ' ')"
}
