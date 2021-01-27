#!/usr/bin/env bash
script_path=$(dirname "$0")
script_path=$(cd -P "$script_path" && pwd)
clear
cd "$script_path" && "./bash_unit" -f tap test_*
