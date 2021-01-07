#!/usr/bin/env bash
### Created by author_name ( author_username ) on meta_today
### Based on https://github.com/pforret/bashew bashew_version
readonly script_author="author@email.com"
readonly script_created="meta_today"
readonly script_prefix=$(basename "${BASH_SOURCE[0]}" .sh)
readonly script_basename=$(basename "${BASH_SOURCE[0]}")
readonly script_folder=$(dirname "${BASH_SOURCE[0]}")
readonly run_as_root=-1 # run_as_root: 0 = don't check anything / 1 = script MUST run as root / -1 = script MAY NOT run as root

script_version="0.0.0" # update version number manually
[[ -f "$script_folder/VERSION.md" ]] && script_version=$(cat "$script_folder/VERSION.md")

#####################################################################
## 1. fill in the usage instructions
#####################################################################
show_usage() {
  out "Program: ${col_grn}$script_basename $script_version${col_reset} by ${col_ylw}$script_author${col_reset}"
  out "Updated: ${col_grn}$script_modified${col_reset}"
  out "Description: package_description"
  out "Usage  : $script_basename [-q] [-v] [-t <target>] <param1>"
  out "    -q : 'quiet' (don't show output)"
  out "    -v : 'verbose' (show more output)"
  out "    -t <target> : use as target"
}

# import .env file with secrets/config
# shellcheck source=/dev/null
[[ -f "$script_folder/.env" ]]  && source "$script_folder/.env"
# shellcheck source=/dev/null
[[ -f "./.env" ]]  && source "./.env"

#####################################################################
## 2. process -f flags and -o <option> options
#####################################################################
verbose=0
quiet=0
target=""
must_show_usage=0
while getopts "qvt:" opt; do
  case ${opt} in
    q ) quiet=1 ;;
    v ) verbose=1 ;;
    t ) target="$OPTARG" ;;
    \? ) must_show_usage=1 ;;
    * ) must_show_usage=1 ;;
  esac
done
shift $((OPTIND -1))

#####################################################################
## 3. process script parameters
#####################################################################
main() {
    out "Program: $script_prefix $script_version"
    log "Created: $script_created"
    log "Updated: $script_modified"
    log "Run as : $USER@$HOSTNAME"
    # add programs you need in your script here, like tar, wget, ffmpeg, rsync ...
    [[ $must_show_usage -gt 0 ]] && show_usage && safe_exit
    verify_programs awk basename cut date dirname find grep head mkdir sed stat tput uname wc

    action=$(lower_case "${1:-}")
    case $action in
    action1 )
        perform_action1 "$target"
        ;;

    action2 )
        perform_action2 "$target"
        ;;

    *) die "action [$action] not recognized"
    esac
}

#####################################################################
## 4. split off chunks of code into functions
#####################################################################
perform_action1(){
  echo "ACTION 1"
  # target=$1
}

perform_action2(){
  echo "ACTION 2"
  # target=$1
}

#####################################################################
################### DO NOT MODIFY BELOW THIS LINE ###################

[[ $run_as_root == 1  ]] && [[ $UID -ne 0 ]] && die "user is $USER, MUST be root to run [$script_basename]"
[[ $run_as_root == -1 ]] && [[ $UID -eq 0 ]] && die "user is $USER, CANNOT be root to run [$script_basename]"

set -uo pipefail
IFS=$'\n\t'

script_modified="??"
os_name=$(uname -s)
[[ "$os_name" = "Linux" ]]  && script_modified=$(stat -c %y    "${BASH_SOURCE[0]}" 2>/dev/null | cut -c1-16) # generic linux
[[ "$os_name" = "Darwin" ]] && script_modified=$(stat -f "%Sm" "${BASH_SOURCE[0]}" 2>/dev/null) # for MacOS

[[ -t 1 ]] && piped=0 || piped=1        # detect if out put is piped
if [[ $piped -eq 0 ]] ; then
  col_reset="\033[0m" ; col_red="\033[1;31m" ; col_grn="\033[1;32m" ; col_ylw="\033[1;33m"
else
  col_reset="" ; col_red="" ; col_grn="" ; col_ylw=""
fi

[[ $(echo -e '\xe2\x82\xac') == '€' ]] && unicode=1 || unicode=0 # detect if unicode is supported
if [[ $unicode -gt 0 ]] ; then
  char_fail="✖" ; char_alrt="➨"
else
  char_fail="!! " ; char_alrt="?? "
fi

out() { ((quiet)) || printf '%b\n' "$*";  }
log()   { ((verbose)) && out "${col_ylw}# $* ${col_reset}" >&2 ; }
die()     { tput bel; out "${col_red}${char_fail} $script_basename${col_reset}: $*" >&2; safe_exit; }
alert()   { out "${col_red}${char_alrt}${col_reset}: $*" >&2 ; }                       # print error and continue
lower_case()   { echo "$*" | awk '{print tolower($0)}' ; }
upper_case()   { echo "$*" | awk '{print toupper($0)}' ; }
error_prefix="${col_red}>${col_reset}"
trap "die \"ERROR \$? after \$SECONDS seconds \n\
\${error_prefix} last command : '\$BASH_COMMAND' \" " INT TERM EXIT

safe_exit() {
  [[ -n "${tmp_file:-}" ]] && [[ -f "$tmp_file" ]] && rm "$tmp_file"
  trap - INT TERM EXIT
  log "$script_basename finished after $SECONDS seconds"
  exit 0
}

verify_programs(){
  os_name=$(uname -s)
  os_version=$(uname -v)
  log "Running: on $os_name ($os_version)"
  list_programs=$(echo "$*" | sort -u |  tr "\n" " ")
  log "Verify : $list_programs"
  for prog in "$@" ; do
    # shellcheck disable=SC2230
    if [[ -z $(which "$prog") ]] ; then
      die "$script_basename needs [$prog] but this program cannot be found on this [$os_name] machine"
    fi
  done
}

main "$@"
safe_exit