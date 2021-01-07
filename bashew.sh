#!/usr/bin/env bash
readonly script_author="peter@forret.com"
# run_as_root: 0 = don't check anything / 1 = script MUST run as root / -1 = script MAY NOT run as root
readonly run_as_root=-1

list_options() {
  echo -n "
#commented lines will be filtered
flag|h|help|show usage
flag|q|quiet|no output
flag|v|verbose|output more
flag|f|force|do not ask for confirmation (always yes)
option|m|model|template script to use: small/normal|normal
option|t|tmpd|folder for temp files|.tmp
option|l|logd|folder for log files|log
option|n|name|name of new script or project
param|1|action|action to perform: script/project/init/update
" | grep -v '^#'
}

list_examples() {
  echo -n "
$script_basename script  : create new (stand-alone) script (interactive)
$script_basename project : create new bash script repo (interactive)
$script_basename init    : initialize this repo as a new project (when generated from the 'bashew' template repo)
$script_basename update  : update $script_basename to latest version (git pull)
" | grep -v '^$'
}
## Put your helper scripts here
get_author_data() {
  # $1 = proposed script/project name

  ## always have something as author data
  guess_fullname="$(whoami)"
  guess_username="$guess_fullname"
  guess_email="$guess_fullname@$(hostname)"

  # if there is prior data, use that
  [[ -n ${BASHEW_AUTHOR_FULLNAME:-} ]] && guess_fullname="$BASHEW_AUTHOR_FULLNAME"
  [[ -n ${BASHEW_AUTHOR_EMAIL:-} ]]    && guess_email="$BASHEW_AUTHOR_EMAIL"
  [[ -n ${BASHEW_AUTHOR_USERNAME:-} ]] && guess_username="$BASHEW_AUTHOR_USERNAME"

  # if there is git config data, use that
  if is_set "$in_git_repo"; then
    guess_fullname=$(git config user.name)
    guess_email=$(git config user.email)
    guess_username=$(git config remote.origin.url | cut -d: -f2)
    # git@github.com:pforret/bashew.git => pforret/bashew.git
    guess_username=$(dirname "$guess_username")
    # pforret/bashew.git => pforret
    guess_username=$(basename "$guess_username")
  fi

  if ((force)) ; then
    author_fullname="$guess_fullname"
    author_email="$guess_email"
    author_username="$guess_username"
    new_name="$1"
    clean_name=$(basename "$new_name" .sh)
    new_description="This is my script $clean_name"
  else
    announce "1. first we need the information of the author"
    author_fullname=$(ask "Author full name        " "$guess_fullname")
    author_email=$(   ask "Author email            " "$guess_email")
    author_username=$(ask "Author (github) username" "$guess_username")
    export BASHEW_AUTHOR_FULLNAME="$author_fullname"
    export BASHEW_AUTHOR_EMAIL="$author_email"
    export BASHEW_AUTHOR_USERNAME="$author_username"

    announce "2. now we need the path and name of this new script/repo"
    new_name=$(ask "Script name" "$1")

    announce "3. give some description of what the script should do"
    clean_name=$(basename "$new_name" .sh)
    new_description=$(ask "Script description" "This is my script $clean_name")
  fi
}

copy_and_replace() {
  local input="$1"
  local output="$2"

  awk \
    -v author_fullname="$author_fullname" \
    -v author_username="$author_username" \
    -v author_email="$author_email" \
    -v package_name="$clean_name" \
    -v package_description="$new_description" \
    -v meta_today="$execution_day" \
    -v meta_year="$execution_year" \
    -v bashew_version="$script_version" \
    '{
    gsub(/author_name/,author_fullname);
    gsub(/author_username/,author_username);
    gsub(/author@email.com/,author_email);
    gsub(/package_name/,package_name);
    gsub(/package_description/,package_description);
    gsub(/meta_today/,meta_today);
    gsub(/meta_year/,meta_year);
    gsub(/bashew_version/,bashew_version);
    print;
    }' \
    < "$input" \
    > "$output"
}

random_word() {
  (
    if aspell -v >/dev/null 2>&1; then
      aspell -d en dump master | aspell -l en expand
    elif [[ -f /usr/share/dict/words ]]; then
      # works on MacOS
      cat /usr/share/dict/words
    elif [[ -f /usr/dict/words ]]; then
      cat /usr/dict/words
    else
      printf 'zero,one,two,three,four,five,six,seven,eight,nine,ten,alfa,bravo,charlie,delta,echo,foxtrot,golf,hotel,india,juliet,kilo,lima,mike,november,oscar,papa,quebec,romeo,sierra,tango,uniform,victor,whiskey,xray,yankee,zulu%.0s' {1..3000} \
      | tr ',' "\n"
    fi
  ) \
    | awk 'length($1) > 2 && length($1) < 8 {print}' \
    | grep -v "'" \
    | grep -v " " \
    | awk "NR == $RANDOM {print tolower(\$0)}"
}

delete_folder(){
  if [[ -d "$1" ]] ; then
    log "Delete folder [$1]"
    rm -fr "$1"
  fi
}
#####################################################################
## Put your main script here
#####################################################################

main() {
  log "Program: $script_basename $script_version"
  log "Updated: $script_modified"
  log "Run as : $USER@$HOSTNAME"
  # add programs you need in your script here, like tar, wget, ffmpeg, rsync ...
  verify_programs tput uname git

  action=$(lcase "$action")
  case $action in
  script)
    if [[ -n "${name:-}" ]] && [[ ! "$name" == " " ]]; then
      log "Using [$name] as name"
      get_author_data "$name"
    else
      random_name="$(random_word)_$(random_word).sh"
      log "Using [$random_name] as name"
      get_author_data "./$random_name"
    fi
    announce "Creating script $new_name ..."
    # shellcheck disable=SC2154
    copy_and_replace "$script_install_folder/template/$model.sh" "$new_name"
    chmod +x "$new_name"
    echo "$new_name"
    ;;

  project)
    if [[ -n "${name:-}" ]] && [[ ! "$name" == " " ]]; then
      get_author_data "$name"
    else
      random_name="$(random_word)_$(random_word)"
      get_author_data "./$random_name"
    fi
    if [[ ! -d "$new_name" ]] ; then
      announce "Creating project $new_name ..."
      mkdir "$new_name"
      template_folder="$script_install_folder/template"
      ## first do all files that can change
      for file in "$template_folder"/*.md "$template_folder/LICENSE" "$template_folder"/.gitignore "$template_folder"/.env.example  ; do
        bfile=$(basename "$file")
        ((quiet)) || echo -n "$bfile "
        new_file="$new_name/$bfile"
        copy_and_replace "$file" "$new_file"
      done
      ((quiet)) || echo -n "$clean_name.sh "
      copy_and_replace "$template_folder/$model.sh" "$new_name/$clean_name.sh"
      chmod +x "$new_name/$clean_name.sh"
      ## now the CI/CD files
      if [[ -f "$template_folder/bitbucket-pipelines.yml" ]] ; then
        ((quiet)) || echo -n "bitbucket-pipelines "
        cp "$template_folder/bitbucket-pipelines.yml" "$new_name/"
      fi
      if [[ -d "$template_folder/.github" ]] ; then
        ((quiet)) || echo -n ".github "
        cp -r "$template_folder/.github" "$new_name/.github"
      fi

      ((quiet)) || echo " "
      if confirm "Do you want to 'git init' the new project?" ; then
        ( pushd "$new_name" && git init && git add . && popd || return) > /dev/null 2>&1
      fi
      success "next step: 'cd $new_name' and start scripting!"
    else
      alert "Folder [$new_name] already exists, cannot make a new project there"
    fi
    ;;

  init)
    repo_name=$(basename "$script_install_folder")
    [[ "$repo_name" == "bashew" ]] && die "You can only run the '$script_basename init' of a *new* repo, derived from the bashew template on Github."
    [[ ! -d ".git" ]] && die "You can only run '$script_basename init' in the root of your repo"
    [[ ! -d "template" ]] && die "The 'template' folder seems to be missing, are you sure this repo is freshly cloned from pforret/bashew?"
    new_name="$repo_name.sh"
    get_author_data "./$new_name"
    announce "Creating script $new_name ..."
    # shellcheck disable=SC2154
    for file in template/*.md template/LICENSE template/.gitignore template/.gitignore  ; do
      bfile=$(basename "$file")
      ((quiet)) || echo -n "$bfile "
      new_file="./$bfile"
      rm -f "$new_file"
      copy_and_replace "$file" "$new_file"
    done
    copy_and_replace "$script_install_folder/template/$model.sh" "$new_name"
    chmod +x "$new_name"
    git add "$new_name"
    alt_dir=$(dirname "$new_name")
    alt_base=$(basename "$new_name" .sh)
    alt_name="$alt_dir/$alt_base"
    if [[ ! "$alt_name" == "$new_name" ]] ; then
      # create a "do_this" alias for "do_this.sh"
      ln -s "$new_name" "$alt_name"
      git add "$alt_name"
    fi
    announce "Now cleaning up unnecessary bashew files ..."
    delete_folder template
    delete_folder assets
    delete_folder .tmp
    delete_folder log
    for remove in tests/test_script.sh tests/test_sourced.sh ; do
        [[ -f "$remove" ]] && rm "$remove"
    done
    log "Delete script [bashew.sh] ..."
    ( sleep 1 ; rm -f bashew.sh bashew ) & # delete will happen after the script is finished
    success "script $new_name created"
    success "proceed with: git commit -a -m 'after bashew init' && git push"
    ;;

  update)
    pushd "$script_install_folder" || die "No access to folder [$script_install_folder]"
    git pull || die "Cannot update with git"
    # shellcheck disable=SC2164
    popd
    ;;

  debug)
    out "print_with_out=yes"
    log "print_with_log=yes"
    announce "print_with_announce=yes"
    success "print_with_success=yes"
    progress "print_with_progress=yes"
    echo ""
    alert "print_with_alert=yes"

    hash3=$(echo "1234567890" | hash 3)
    hash6=$(echo "1234567890" | hash)
    out "hash3=$hash3"
    out "hash6=$hash6"
    out "script_basename=$script_basename"
    out "script_author=$script_author"
    out "escape1 = $(escape "/forward/slash")"
    out "escape2 = $(escape '\backward\slash')"
    out "lowercase = $(lcase 'AbCdEfGhIjKlMnÔû')"
    out "uppercase = $(ucase 'AbCdEfGhIjKlMnÔû')"
    # shellcheck disable=SC2015
    is_set "$force" && out "force=$force (true)" || out "force=$force (false)"
    ;;

    *)

    die "param [$action] not recognized"
    ;;
  esac
}

#####################################################################
################### DO NOT MODIFY BELOW THIS LINE ###################

# set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# removed -e because it made basic [[ testing ]] difficult
set -uo pipefail
IFS=$'\n\t'
# shellcheck disable=SC2120
hash(){
  length=${1:-6}
  # shellcheck disable=SC2230
  if [[ -n $(which md5sum) ]] ; then
    # regular linux
    md5sum | cut -c1-"$length"
  else
    # macos
    md5 | cut -c1-"$length"
  fi
}

force=0
help=0

## ----------- TERMINAL OUTPUT STUFF

[[ -t 1 ]] && piped=0 || piped=1 # detect if out put is piped
verbose=0
#to enable verbose even before option parsing
[[ $# -gt 0 ]] && [[ $1 == "-v" ]] && verbose=1
quiet=0
#to enable quiet even before option parsing
[[ $# -gt 0 ]] && [[ $1 == "-q" ]] && quiet=1

[[ $(echo -e '\xe2\x82\xac') == '€' ]] && unicode=1 || unicode=0 # detect if unicode is supported

if [[ $piped -eq 0 ]]; then
  col_reset="\033[0m"
  col_red="\033[1;31m"
  col_grn="\033[1;32m"
  col_ylw="\033[1;33m"
else
  col_reset=""
  col_red=""
  col_grn=""
  col_ylw=""
fi

if [[ $unicode -gt 0 ]]; then
  char_succ="✔"
  char_fail="✖"
  char_alrt="➨"
  char_wait="…"
else
  char_succ="OK "
  char_fail="!! "
  char_alrt="?? "
  char_wait="..."
fi

readonly nbcols=$(tput cols || echo 80)
#readonly nbrows=$(tput lines)
readonly wprogress=$((nbcols - 5))

out() { ((quiet)) || printf '%b\n' "$*"; }

progress() {
  ((quiet)) || (
    ((piped)) && out "$*" || printf "... %-${wprogress}b\r" "$*                                             "
  )
}

die() {
  tput bel
  out "${col_red}${char_fail} $script_basename${col_reset}: $*" >&2
  safe_exit
}

alert() { out "${col_red}${char_alrt}${col_reset}: $*" >&2; } # print error and continue
success() { out "${col_grn}${char_succ}${col_reset}  $*"; }
announce() { out "${col_grn}${char_wait}${col_reset}  $*" ; sleep 1 ;}
log() { ((verbose)) && out "${col_ylw}# $* ${col_reset}" >&2; }

escape() { echo "$*" | sed 's/\//\\\//g'; }

lcase() { echo "$*" | awk '{print tolower($0)}'; }
ucase() { echo "$*" | awk '{print toupper($0)}'; }

confirm() {
  is_set $force && return 0
  read -r -p "$1 [y/N] " -n 1
  echo " "
  [[ $REPLY =~ ^[Yy]$ ]]
}
#TIP: use «confirm» for interactive confirmation before doing something
#TIP:> if ! confirm "Delete file"; then ; echo "skip deletion" ;   fi

ask() {
  # value=$(ask_question <question> <default>)
  # usage
  local answer
  read -r -p "$1 ($2): " answer
  echo "${answer:-$2}"
}

error_prefix="${col_red}>${col_reset}"
trap "die \"ERROR \$? after \$SECONDS seconds \n\
\${error_prefix} last command : '\$BASH_COMMAND' \" \
\$(< \$script_install_path awk -v lineno=\$LINENO \
'NR == lineno {print \"\${error_prefix} from line \" lineno \" : \" \$0}')" INT TERM EXIT
# cf https://askubuntu.com/questions/513932/what-is-the-bash-command-variable-good-for
# trap 'echo ‘$BASH_COMMAND’ failed with error code $?' ERR
safe_exit() {
  [[ -n "$tmpfile" ]] && [[ -f "$tmpfile" ]] && rm "$tmpfile"
  trap - INT TERM EXIT
  log "$script_basename finished after $SECONDS seconds"
  exit 0
}

is_set() { [[ "$1" -gt 0 ]]; }
is_empty() { [[ -z "$1" ]]; }
is_not_empty() { [[ -n "$1" ]]; }
#TIP: use «is_empty» and «is_not_empty» to test for variables
#TIP:> if is_empty "$email" ; then ; echo "Need Email!" ; fi

is_file() { [[ -f "$1" ]]; }
is_dir() { [[ -d "$1" ]]; }
#TIP: use «is_file» and «is_dir» to test for files or folders
#TIP:> if is_file "/etc/hosts" ; then ; cat "/etc/hosts" ; fi

show_usage() {
  out "Program: ${col_grn}$script_basename $script_version${col_reset} by ${col_ylw}$script_author${col_reset}"
  out "Updated: ${col_grn}$script_modified${col_reset}"

  echo -n "Usage: $script_basename"
  list_options |
    awk '
  BEGIN { FS="|"; OFS=" "; oneline="" ; fulltext="Flags, options and parameters:"}
  $1 ~ /flag/  {
    fulltext = fulltext sprintf("\n    -%1s|--%-10s: [flag] %s [default: off]",$2,$3,$4) ;
    oneline  = oneline " [-" $2 "]"
    }
  $1 ~ /option/  {
    fulltext = fulltext sprintf("\n    -%1s|--%s <%s>: [optn] %s",$2,$3,"val",$4) ;
    if($5!=""){fulltext = fulltext "  [default: " $5 "]"; }
    oneline  = oneline " [-" $2 " <" $3 ">]"
    }
  $1 ~ /secret/  {
    fulltext = fulltext sprintf("\n    -%1s|--%s <%s>: [secr] %s",$2,$3,"val",$4) ;
      oneline  = oneline " [-" $2 " <" $3 ">]"
    }
  $1 ~ /param/ {
    if($2 == "1"){
          fulltext = fulltext sprintf("\n    %-10s: [parameter] %s","<"$3">",$4);
          oneline  = oneline " <" $3 ">"
     } else {
          fulltext = fulltext sprintf("\n    %-10s: [parameters] %s (1 or more)","<"$3">",$4);
          oneline  = oneline " <" $3 " …>"
     }
    }
    END {print oneline; print fulltext}
  '
}

show_tips() {
  grep <"${BASH_SOURCE[0]}" -v "\$0" |
    awk "
  /TIP: / {\$1=\"\"; gsub(/«/,\"$col_grn\"); gsub(/»/,\"$col_reset\"); print \"*\" \$0}
  /TIP:> / {\$1=\"\"; print \" $col_ylw\" \$0 \"$col_reset\"}
  "
}

init_options() {
  local init_command
  init_command=$(list_options |
    awk '
    BEGIN { FS="|"; OFS=" ";}
    $1 ~ /flag/   && $5 == "" {print $3"=0; "}
    $1 ~ /flag/   && $5 != "" {print $3"="$5"; "}
    $1 ~ /option/ && $5 == "" {print $3"=\" \"; "}
    $1 ~ /option/ && $5 != "" {print $3"="$5"; "}
    ')
  if [[ -n "$init_command" ]]; then
    #log "init_options: $(echo "$init_command" | wc -l) options/flags initialised"
    eval "$init_command"
  fi
}

verify_programs() {
  os_uname=$(uname -s)
  os_version=$(uname -v)
  log "Running: on $os_uname ($os_version)"
  list_programs=$(echo "$*" | sort -u | tr "\n" " ")
  log "Verify : $list_programs"
  for prog in "$@"; do
    # shellcheck disable=SC2230
    if [[ -z $(which "$prog") ]]; then
      die "$script_basename needs [$prog] but this program cannot be found on this $os_uname machine"
    fi
  done
}

folder_prep() {
  if [[ -n "$1" ]]; then
    local folder="$1"
    local max_days=${2:-365}
    if [[ ! -d "$folder" ]]; then
      log "Create folder [$folder]"
      mkdir "$folder"
    else
      log "Cleanup: [$folder] - delete files older than $max_days day(s)"
      find "$folder" -mtime "+$max_days" -type f -exec rm {} \;
    fi
  fi
}

expects_single_params() {
  list_options | grep 'param|1|' >/dev/null
}
expects_multi_param() {
  list_options | grep 'param|n|' >/dev/null
}

parse_options() {
  if [[ $# -eq 0 ]]; then

    show_usage >&2
    safe_exit
  fi

  ## first process all the -x --xxxx flags and options
  #set -x
  while true; do
    # flag <flag> is savec as $flag = 0/1
    # option <option> is saved as $option
    if [[ $# -eq 0 ]]; then
      ## all parameters processed
      break
    fi
    if [[ ! $1 == -?* ]]; then
      ## all flags/options processed
      break
    fi
    local save_option
    save_option=$(list_options |
      awk -v opt="$1" '
        BEGIN { FS="|"; OFS=" ";}
        $1 ~ /flag/   &&  "-"$2 == opt {print $3"=1"}
        $1 ~ /flag/   && "--"$3 == opt {print $3"=1"}
        $1 ~ /option/ &&  "-"$2 == opt {print $3"=$2; shift"}
        $1 ~ /option/ && "--"$3 == opt {print $3"=$2; shift"}
        $1 ~ /secret/ &&  "-"$2 == opt {print $3"=$2; shift"}
        $1 ~ /secret/ && "--"$3 == opt {print $3"=$2; shift"}
        ')
    if [[ -n "$save_option" ]]; then
      if echo "$save_option" | grep shift >>/dev/null; then
        local save_var
        save_var=$(echo "$save_option" | cut -d= -f1)
        log "Found  : ${save_var}=$2"
      else
        log "Found  : $save_option"
      fi
      eval "$save_option"
    else
      die "cannot interpret option [$1]"
    fi
    shift
  done

  ((help)) && (
    echo "### USAGE"
    show_usage
    echo "### EXAMPLES"
    list_examples
    safe_exit
  )

  ## then run through the given parameters
  if expects_single_params; then
    single_params=$(list_options | grep 'param|1|' | cut -d'|' -f3)
    list_singles=$(echo "$single_params" | xargs)
    nb_singles=$(echo "$single_params" | wc -w)
    log "Expect : $nb_singles single parameter(s): $list_singles"
    [[ $# -eq 0 ]] && die "need the parameter(s) [$list_singles]"

    for param in $single_params; do
      [[ $# -eq 0 ]] && die "need parameter [$param]"
      [[ -z "$1" ]] && die "need parameter [$param]"
      log "Found  : $param=$1"
      eval "$param=$1"
      shift
    done
  else
    log "No single params to process"
    single_params=""
    nb_singles=0
  fi

  if expects_multi_param; then
    #log "Process: multi param"
    nb_multis=$(list_options | grep -c 'param|n|')
    multi_param=$(list_options | grep 'param|n|' | cut -d'|' -f3)
    log "Expect : $nb_multis multi parameter: $multi_param"
    [[ $nb_multis -gt 1 ]] && die "cannot have >1 'multi' parameter: [$multi_param]"
    [[ $nb_multis -gt 0 ]] && [[ $# -eq 0 ]] && die "need the (multi) parameter [$multi_param]"
    # save the rest of the params in the multi param
    if [[ -n "$*" ]]; then
      log "Found  : $multi_param=$*"
      eval "$multi_param=( $* )"
    fi
  else
    log "No multi param to process"
    nb_multis=0
    multi_param=""
    [[ $# -gt 0 ]] && die "cannot interpret extra parameters"
    log "all parameters have been processed"
  fi
}

tmpfile=""
logfile=""

recursive_readlink(){
  [[ ! -h "$1" ]] && echo "$1" && return 0
  local file_folder
  local link_folder
  local link_name
  file_folder="$(dirname "$1")"
  # resolve relative to absolute path
  [[ "$file_folder" != /* ]] && link_folder="$(cd -P "$file_folder" >/dev/null 2>&1 && pwd)"
  local  symlink
  symlink=$(readlink "$1")
  link_folder=$(dirname "$symlink")
  link_name=$(basename "$symlink")
  [[ -z "$link_folder" ]] && link_folder="$file_folder"
  [[ "$link_folder" = \.* ]] && link_folder="$(cd -P "$file_folder" && cd -P "$link_folder" >/dev/null 2>&1 && pwd)"
  log "Symbolic ln: $1 -> [$symlink]"
  recursive_readlink "$link_folder/$link_name"
}

lookup_script_data() {
  readonly script_prefix=$(basename "${BASH_SOURCE[0]}" .sh)
  readonly script_basename=$(basename "${BASH_SOURCE[0]}")
  readonly execution_day=$(date "+%Y-%m-%d")
  readonly execution_year=$(date "+%Y")

  script_install_path="${BASH_SOURCE[0]}"
  log "Script path: $script_install_path"
  script_install_path=$(recursive_readlink "$script_install_path")
  log "Actual path: $script_install_path"
  readonly script_install_folder="$(dirname "$script_install_path")"

  script_modified="??"
  os_uname=$(uname -s)
  [[ "$os_uname" == "Linux" ]]  && script_modified=$(stat -c "%y"  "$script_install_path" 2>/dev/null | cut -c1-16) # generic linux
  [[ "$os_uname" == "Darwin" ]] && script_modified=$(stat -f "%Sm" "$script_install_path" 2>/dev/null)          # for MacOS

  # get shell/operating system/versions
  shell_brand="sh"
  shell_version="?"
  [[ -n "${ZSH_VERSION:-}" ]]  && shell_brand="zsh"  && shell_version="$ZSH_VERSION"
  [[ -n "${BASH_VERSION:-}" ]] && shell_brand="bash" && shell_version="$BASH_VERSION"
  [[ -n "${FISH_VERSION:-}" ]] && shell_brand="fish" && shell_version="$FISH_VERSION"
  [[ -n "${KSH_VERSION:-}" ]]  && shell_brand="ksh"  && shell_version="$KSH_VERSION"
  log "Shell type : $shell_brand - version $shell_version"

  readonly os_kernel=$(uname -s)
  os_version=$(uname -r)
  os_machine=$(uname -m)
  case "$os_kernel" in
  CYGWIN*|MSYS*|MINGW*)
    os_name="Windows"
    ;;
  Darwin)
    os_name=$(sw_vers -productName) # macOS
    os_version=$(sw_vers -productVersion) # 11.1
    ;;
  Linux|GNU*)
    if [[ $(which lsb_release) ]] ; then
      # 'normal' Linux distributions
      os_name=$(lsb_release -i) # Ubuntu
      os_version=$(lsb_release -r) # 20.04
    else
      # Synology, QNAP,
      os_name="Linux"
    fi
  esac
  log "OS Version : $os_name ($os_kernel) $os_version on $os_machine"

  script_version=0.0.0
  [[ -f "$script_install_folder/VERSION.md" ]] && script_version=$(cat "$script_install_folder/VERSION.md")
  if git status >/dev/null 2>&1; then
    readonly in_git_repo=1
  else
    readonly in_git_repo=0
  fi
}

prep_log_and_temp_dir() {
  tmpfile=""
  if [[ -n "${tmpd:-}" ]]; then
    folder_prep "$tmpd" 1
    tmpfile=$(mktemp "$tmpd/$execution_day.XXXXXX")
    log "Tmpfile: $tmpfile"
    # you can use this temporary file in your program
    # it will be deleted automatically when the program ends
  fi
  logfile=""
  if [[ -n "${logd:-}" ]]; then
    folder_prep "$logd" 7
    logfile=$logd/$script_prefix.$execution_day.log
    log "Logfile: $logfile"
    echo "$(date '+%H:%M:%S') | [$script_basename] $script_version started" >>"$logfile"
  fi
}

[[ $run_as_root == 1 ]] && [[ $UID -ne 0 ]] && die "MUST be root to run this script"
[[ $run_as_root == -1 ]] && [[ $UID -eq 0 ]] && die "CANNOT be root to run this script"

lookup_script_data

# set default values for flags & options
init_options

# overwrite with specified options if any
parse_options "$@"

# clean up log and temp folder
prep_log_and_temp_dir

# run main program
main

# exit and clean up
safe_exit
