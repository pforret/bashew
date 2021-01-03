#!/usr/bin/env bash
script_path=$(dirname "$0")
script_path=$(cd -P "$script_path" && pwd)
"$script_path/bash_unit" "$script_path/test_*"
