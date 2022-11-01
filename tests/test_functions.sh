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
    echo "script ["../template/script.sh"] could not be found"
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
