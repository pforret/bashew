#!/usr/bin/env bash
script_path=$(dirname "$0")
script_path=$(cd -P "$script_path" && pwd)
tested=0

clear
# check if bash_unit is installed
test_unit=$(command -v bash_unit)
if [[ -x "$test_unit" ]] ; then
  cd "$script_path" && "$test_unit" -f tap test_*
  tested=1
fi

if [[ $tested -eq 0  ]] ; then
  echo "This script uses https://github.com/pgrange/bash_unit for bash unit testing"
  os_name="$(uname -s)"
  [[ "$os_name" == "Darwin" ]] && echo "Use 'brew install bash_unit' to install bash_unit"
fi