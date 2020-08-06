#!/usr/bin/env bash
### ==============================================================================
### SO HOW DO YOU PROCEED WITH YOUR SCRIPT?
### 1. run "script.sh init"
### 2. define the options/parameters and defaults you need in list_options() 
### 3. define functions your might need by changing/adding to perform_action1()
### 4. add binaries your script needs (e.g. ffmpeg) to verify_programs awk (...) wc
### 5. implement the different actions you defined in 2. in main()
### ==============================================================================

readonly PROGVERS="@version"
readonly PROGAUTH="@email"
# uncomment next line to have time prefix for every output line
#prefix_fmt='+%H:%M:%S | '
readonly prefix_fmt=""

# runasroot = 0 :: don't check anything
# runasroot = 1 :: script MUST run as root
# runasroot = -1 :: script MAY NOT run as root
runasroot=-1

list_options() {
  ### Change the next lines to reflect which flags/options/parameters you need
  ### flag:   switch a flag 'on' / no extra parameter / e.g. "-v" for verbose
  ### flag|<short>|<long>|<description>|<default>
  ### option: set an option value / 1 extra parameter / e.g. "-l error.log" for logging to file
  ### option|<short>|<long>|<description>|<default>
  ### param:  comes after the options
  ### param|<type>|<long>|<description>
  ### where <type> = 1 for single parameters or <type> = n for (last) parameter that can be a list
echo -n "
#commented lines will be filtered
flag|h|help|show usage
flag|q|quiet|no output
flag|v|verbose|output more
flag|f|force|do not ask for confirmation (always yes)
option|l|logd|folder for log files |log
option|t|tmpd|folder for temp files|.tmp
#you could also use /tmp/$PROGNAME as the default temp folder
#option|u|user|USER to use|$USER
#secret|p|pass|password to use
param|1|action|action to perform: init/list/test/...
# there can only be 1 param|n and it should be the last
param|1|output|output file
param|n|inputs|input files
" | grep -v '^#'
}

## Put your helper scripts here

perform_action1(){
  OUTPUT="$1"
  shift
  echo INPUTS = "$*"
  echo OUTPUT = "$OUTPUT"
  # < "$1"  do_stuff > "$2"
}

perform_action2(){
  OUTPUT="$1"
  shift
  echo INPUTS = "$*"
  echo OUTPUT = "$OUTPUT"
  # < "$1"  do_stuff > "$2"
}

#####################################################################
## Put your main script here
#####################################################################

main() {
    log "Program: $PROGFNAME $PROGVERS ($PROGUUID)"
    log "Updated: $PROGDATE"
    log "Run as : $USER@$HOSTNAME"
    # add programs you need in your script here, like tar, wget, ffmpeg, rsync ...
    verify_programs awk basename cut date dirname find grep head mkdir sed stat tput uname wc
    prep_log_and_temp_dir

    action=$(lcase "$action")
    case $action in
    init )
        create_script_from_template
        ;;

    test )
        run_tests
        ;;

    action2 )
        #perform_action2 "$output" $inputs
        ;;

    *)
        die "param [$action] not recognized"
    esac
}

#####################################################################
################### DO NOT MODIFY BELOW THIS LINE ###################

# set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# removed -e because it made basic [[ testing ]] difficult
set -uo pipefail
IFS=$'\n\t'
hash(){
  if [[ -n $(which md5sum) ]] ; then
    # regular linux
    md5sum | cut -c1-6
  else
    # macos
    md5 | cut -c1-6
  fi 
}

# change program version to your own release logic
readonly PROGNAME=$(basename "$0" .sh)
readonly PROGFNAME=$(basename "$0")
readonly PROGDIRREL=$(dirname "$0")
if [[ -z "$PROGDIRREL" ]] ; then
	# script called without  path specified ; must be in $PATH somewhere
  readonly PROGFULLPATH=$(which "$0")
  readonly PROGDIR=$(dirname "$PROGFULLPATH")
else
  readonly PROGDIR=$(cd "$PROGDIRREL" && pwd)
  readonly PROGFULLPATH="$PROGDIR/$PROGFNAME"
fi
readonly PROGLINES=$(< "$PROGFULLPATH" awk 'END {print NR}')
readonly PROGHASH=$(< "$PROGFULLPATH" hash)
readonly PROGUUID="L:${PROGLINES}-MD:${PROGHASH}"
# this is version of bash-boilerplate - replace by versioning of your script; start at 1.0.0
readonly TODAY=$(date "+%Y-%m-%d")
readonly PROGIDEN="«${PROGNAME} ${PROGVERS}»"
[[ -z "${TEMP:-}" ]] && TEMP=/tmp

PROGDATE="??"
os_uname=$(uname -s)
[[ "$os_uname" = "Linux" ]]  && PROGDATE=$(stat -c %y "$0" 2>/dev/null | cut -c1-16) # generic linux
[[ "$os_uname" = "Darwin" ]] && PROGDATE=$(stat -f "%Sm" "$0" 2>/dev/null) # for MacOS

verbose=0
quiet=0
piped=0
force=0
help=0
tmpd="$TEMP/$PROGNAME"
logd="./log"

[[ $# -gt 0 ]] && [[ $1 == "-v" ]] && verbose=1
#to enable verbose even for option parsing

[[ -t 1 ]] && piped=0 || piped=1        # detect if out put is piped
[[ $(echo -e '\xe2\x82\xac') == '€' ]] && unicode=1 || unicode=0 # detect if unicode is supported

# Defaults

if [[ $piped -eq 0 ]] ; then
  readonly col_reset="\033[0m"
  readonly col_red="\033[1;31m"
  readonly col_grn="\033[1;32m"
  readonly col_ylw="\033[1;33m"
else
  # no colors for piped content
  readonly col_reset=""
  readonly col_red=""
  readonly col_grn=""
  readonly col_ylw=""
fi

if [[ $unicode -gt 0 ]] ; then
  readonly char_succ="✔"
  readonly char_fail="✖"
  readonly char_alrt="➨"
  readonly char_wait="…"
else
  # no unicode chars if not supported
  readonly char_succ="OK "
  readonly char_fail="!! "
  readonly char_alrt="?? "
  readonly char_wait="..."
fi

readonly nbcols=$(tput cols || echo 80)
readonly wprogress=$((nbcols - 5))
#readonly nbrows=$(tput lines)

tmpfile=""
logfile=""

out() {
  ((quiet)) && return
  local message="$*"
  local prefix=""
  if is_not_empty "$prefix_fmt" ; then
    prefix=$(date "$prefix_fmt")
  fi
  printf '%b\n' "$prefix$message";
}
#TIP: use «out» to show any kind of output, except when option --quiet is specified
#TIP:> out "User is [$USER]"

progress() {
  ((quiet)) && return
  local message="$*"
  if ((piped)); then
    printf '%b\n' "$message";
    # \r makes no sense in file or pipe
  else
    printf "... %-${wprogress}b\r" "$message                                             ";
    # next line will overwrite this line
  fi
}
#TIP: use «progress» to show one line of progress that will be overwritten by the next output
#TIP:> progress "Now generating file $nb of $total ..."

error_prefix="${col_red}>${col_reset}"
trap "die \"ERROR \$? after \$SECONDS seconds \n\
\${error_prefix} last command : '\$BASH_COMMAND' \" \
\$(< \$PROGFULLPATH awk -v lineno=\$LINENO \
'NR == lineno {print \"\${error_prefix} from line \" lineno \" : \" \$0}')" INT TERM EXIT
# cf https://askubuntu.com/questions/513932/what-is-the-bash-command-variable-good-for
# trap 'echo ‘$BASH_COMMAND’ failed with error code $?' ERR
safe_exit() { 
  [[ -n "$tmpfile" ]] && [[ -f "$tmpfile" ]] && rm "$tmpfile"
  trap - INT TERM EXIT
  exit 0
}

is_set()       { [[ "$1" -gt 0 ]]; }
is_empty()     { [[ -z "$1" ]] ; }
is_not_empty() { [[ -n "$1" ]] ; }
#TIP: use «is_empty» and «is_not_empty» to test for variables
#TIP:> if is_empty "$email" ; then ; echo "Need Email!" ; fi

is_file() { [[ -f "$1" ]] ; }
is_dir()  { [[ -d "$1" ]] ; }


die()     { tput bel; out "${col_red}${char_fail} $PROGIDEN${col_reset}: $*" >&2; safe_exit; }
fail()    { tput bel; out "${col_red}${char_fail} $PROGIDEN${col_reset}: $*" >&2; safe_exit; }
#TIP: use «die» to show error message and exit program
#TIP:> if [[ ! -f $output ]] ; then ; die "could not create output" ; fi

alert()   { out "${col_red}${char_alrt}${col_reset}: $*" >&2 ; }                       # print error and continue
#TIP: use «alert» to show alert message but continue
#TIP:> if [[ ! -f $output ]] ; then ; alert "could not create output" ; fi

success() { out "${col_grn}${char_succ}${col_reset}  $*"; }
#TIP: use «success» to show success message but continue
#TIP:> if [[ -f $output ]] ; then ; success "output was created!" ; fi

announce(){ out "${col_grn}${char_wait}${col_reset}  $*"; sleep 1 ; }
#TIP: use «announce» to show the start of a task
#TIP:> announce "now generating the reports"

log()   { is_set $verbose && out "${col_ylw}# $* ${col_reset}" ; }
debug() { is_set $verbose && out "${col_ylw}# $* ${col_reset}" ; }
#TIP: use «log» to show information that will only be visible when -v is specified
#TIP:> log "input file: [$inputname] - [$inputsize] MB"
	  
escape()  { echo "$*" | sed 's/\//\\\//g' ; }
#TIP: use «escape» to extra escape '/' paths in regex
#TIP:> sed 's/$(escape $path)//g'

lcase()   { echo "$*" | awk '{print tolower($0)}' ; }
ucase()   { echo "$*" | awk '{print toupper($0)}' ; }
#TIP: use «lcase» and «ucase» to convert to upper/lower case
#TIP:> param=$(lcase $param)

confirm() { is_set $force && return 0; read -r -p "$1 [y/N] " -n 1; echo " "; [[ $REPLY =~ ^[Yy]$ ]];}
#TIP: use «confirm» for interactive confirmation before doing something
#TIP:> if ! confirm "Delete file"; then ; echo "skip deletion" ;   fi

ask() { 
  # $1 = variable name
  # $2 = question
  # $3 = default value  
  # not using read -i because that doesn't work on MacOS
  local ANSWER
  read -r -p "$2 ($3) > " ANSWER
  if [[ -z "$ANSWER" ]] ; then
    eval "$1=\"$3\""
  else
    eval "$1=\"$ANSWER\""
  fi
}
#TIP: use «ask» for interactive setting of variables
#TIP:> ask NAME "What is your name" "Peter"


os_uname=$(uname -s)
os_bits=$(uname -m)
os_version=$(uname -v)

on_mac()	  { [[ "$os_uname" = "Darwin" ]] ;	}
on_linux()	{ [[ "$os_uname" = "Linux" ]] ;	}

on_32bit()	{ [[ "$os_bits"  = "i386" ]] ;	}
on_64bit()	{ [[ "$os_bits"  = "x86_64" ]] ;	}
#TIP: use «on_mac»/«on_linux»/'on_32bit'/'on_64bit' to only run things on certain platforms
#TIP:> on_mac && log "Running on MacOS"

usage() {
  out "Program: ${col_grn}$PROGFNAME${col_reset} by ${col_ylw}$PROGAUTH${col_reset}"
  out "Version: ${col_grn}$PROGVERS${col_reset} (${col_ylw}$PROGUUID${col_reset})"
  out "Updated: ${col_grn}$PROGDATE${col_reset}"

  echo -n "Usage: $PROGFNAME"
   list_options \
  | awk '
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

tips(){
  < "$0" grep -v "\$0" \
  | awk "
  /TIP: / {\$1=\"\"; gsub(/«/,\"$col_grn\"); gsub(/»/,\"$col_reset\"); print \"*\" \$0}
  /TIP:> / {\$1=\"\"; print \" $col_ylw\" \$0 \"$col_reset\"}
  "
}

init_options() {
	local init_command
    init_command=$(list_options \
    | awk '
    BEGIN { FS="|"; OFS=" ";}
    $1 ~ /flag/   && $5 == "" {print $3"=0; "}
    $1 ~ /flag/   && $5 != "" {print $3"="$5"; "}
    $1 ~ /option/ && $5 == "" {print $3"=\" \"; "}
    $1 ~ /option/ && $5 != "" {print $3"="$5"; "}
    ')
    if [[ -n "$init_command" ]] ; then
        #log "init_options: $(echo "$init_command" | wc -l) options/flags initialised"
        eval "$init_command"
   fi
}

run_only_show_errors(){
  tmpfile=$(mktemp)
  if ( "$@" ) 2>> "$tmpfile" >> "$tmpfile" ; then
    #all OK
    rm "$tmpfile"
    return 0
  else
    alert "[$*] gave an error"
    cat "$tmpfile"
    rm "$tmpfile"
    return 255
  fi
}

verify_programs(){
  log "Running: on $os_uname ($os_version)"
  list_programs=$(echo "$*" | sort -u |  tr "\n" " ")
  hash_programs=$(echo "$list_programs" | hash)
  verify_cache="$PROGDIR/.$PROGNAME.$hash_programs.verified"
  if [[ -f "$verify_cache" ]] ; then
    log "Verify : $list_programs (cached)"
  else 
    log "Verify : $list_programs"
    programs_ok=1
    for prog in "$@" ; do
      if [[ -z $(which "$prog") ]] ; then
        alert "$PROGIDEN needs [$prog] but this program cannot be found on this $os_uname machine"
        programs_ok=0
      fi
    done
    if [[ $programs_ok -eq 1 ]] ; then
      (
        echo "$PROGNAME: check required programs OK"
        echo "$list_programs"
        date 
      ) > "$verify_cache"
    fi
  fi
}

folder_prep(){
    if [[ -n "$1" ]] ; then
        local folder="$1"
        local maxdays=365
        if [[ -n "$2" ]] ; then
            maxdays=$2
        fi
        if [ ! -d "$folder" ] ; then
            log "Create folder [$folder]"
            mkdir "$folder"
        else
            log "Cleanup: [$folder] - delete files older than $maxdays day(s)"
            find "$folder" -mtime "+$maxdays" -type f -exec rm {} \;
        fi
	fi
}
#TIP: use «folder_prep» to create a folder if needed and otherwise clean up old files
#TIP:> folder_prep "$logd" 7 # delete all files olders than 7 days

expects_single_params(){
  list_options | grep 'param|1|' > /dev/null
}

expects_multi_param(){
  list_options | grep 'param|n|' > /dev/null
}

parse_options() {
    if [[ $# -eq 0 ]] ; then
       usage >&2 ; safe_exit
    fi

    ## first process all the -x --xxxx flags and options
    #set -x
    while true; do
      # flag <flag> is savec as $flag = 0/1
      # option <option> is saved as $option
      if [[ $# -eq 0 ]] ; then
        ## all parameters processed
        break
      fi
      if [[ ! $1 = -?* ]] ; then
        ## all flags/options processed
        break
      fi
	  local save_option
      save_option=$(list_options \
        | awk -v opt="$1" '
        BEGIN { FS="|"; OFS=" ";}
        $1 ~ /flag/   &&  "-"$2 == opt {print $3"=1"}
        $1 ~ /flag/   && "--"$3 == opt {print $3"=1"}
        $1 ~ /option/ &&  "-"$2 == opt {print $3"=$2; shift"}
        $1 ~ /option/ && "--"$3 == opt {print $3"=$2; shift"}
        ')
        if [[ -n "$save_option" ]] ; then
          if echo "$save_option" | grep shift >> /dev/null ; then
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

    if [[ $help -gt 0 ]] ; then
      echo "### USAGE"
      usage
      echo ""
      echo "### SCRIPT AUTHORING TIPS"
      tips
      safe_exit
    fi

    # special case: init
    if [[ $(lcase "$1") == "init" ]] ; then
      action="init"
      return
    fi
    if [[ $(lcase "$1") == "test" ]] ; then
      action="test"
      return
    fi
    ## then run through the given parameters
  if expects_single_params ; then
    #log "Process: single params"
    single_params=$(list_options | grep 'param|1|' | cut -d'|' -f3 | xargs)
    nb_singles=$(echo "$single_params" | wc -w)
    log "Expect : $nb_singles single parameter(s): $single_params"
    [[ $# -eq 0 ]] && die "need the parameter(s) [$single_params]"


    for param in $single_params ; do
      [[ $# -eq 0 ]] && die "need parameter [$param]"
      [[ -z "$1" ]]  && die "need parameter [$param]"
      log "Found  : $param=$1"
      eval "$param=$1"
      shift
    done
  else 
    log "No single params to process"
    single_params=""
    nb_singles=0
  fi

  if expects_multi_param ; then
    #log "Process: multi param"
    nb_multis=$(list_options | grep -c 'param|n|')
    multi_param=$(list_options | grep 'param|n|' | cut -d'|' -f3)
    log "Expect : $nb_multis multi parameter: $multi_param"
    [[ $nb_multis -gt 1 ]]  && die "cannot have >1 'multi' parameter: [$multi_param]"
    [[ $nb_multis -gt 0 ]] && [[ $# -eq 0 ]] && die "need the (multi) parameter [$multi_param]"
    # save the rest of the params in the multi param
    if [[ -n "$*" ]] ; then
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

create_script_from_template(){
  out "## SCRIPT INITIALISATION"
  if [[ "@email" == @* ]] ; then
    out "let's create a new project and remove everything you don't need!"
    ask EMAIL "What is your email address?" "$USER@$HOSTNAME"
    ask NEWNAME "What is the name of your script?" "newscript.sh"
    ask VERSION "What is the version of your script?" "1.0.0"
    < "$PROGFULLPATH" awk -v email="$EMAIL" -v version="$VERSION" '{gsub(/@version/,version); gsub(/@email/,email); print$0}' > "$NEWNAME"
    if [[ -d $PROGDIR/usage ]] ; then
      if confirm "Delete all non-essential files? "; then
        rm -fr "$PROGDIR/usage"
        rm -fr "$PROGDIR/docs"
      fi
    fi
  else
    die "This is no longer a template script, it was already initialised by @email - please start from original script.sh"
  fi
}

run_tests(){
    # just show all options/params with values
  show_commands=$(list_options \
    | awk '
    BEGIN { FS="|"; OFS=" ";}
    $1 ~ /flag|option/ {print "out \"-" $2 "/--" $3 " = $" $3 " (" $1 ")\""}
    $1 ~ /param/ {print "out \"[" $3 "] (" $1 ")\""}
    ')
    if [[ -n "$show_commands" ]] ; then
        eval "$show_commands"
   fi
}

prep_log_and_temp_dir(){
  if [[ -n "$tmpd" ]] ; then
    folder_prep "$tmpd" 1
    tmpfile=$(mktemp "$tmpd/$TODAY.XXXXXX")
    log "Tmpfile: $tmpfile"
    # you can use this teporary file in your program
    # it will be deleted automatically if the program ends without problems
  fi
  if [[ -n "$logd" ]] ; then
    folder_prep "$logd" 7
    logfile=$logd/$PROGNAME.$TODAY.log
    log "Logfile: $logfile"
    echo "$(date '+%H:%M:%S') | [$PROGFNAME] $PROGVERS ($PROGUUID) started" >> "$logfile"
  fi
}
[[ $runasroot == 1  ]] && [[ $UID -ne 0 ]] && die "MUST be root to run this script"
[[ $runasroot == -1 ]] && [[ $UID -eq 0 ]] && die "CANNOT be root to run this script"


 # this will show up even if your main() has errors
log "-------- PREPARE $PROGIDEN"
init_options
parse_options "$@"
# this will show up even if your main() has errors
log "-------- STARTING (main) $PROGIDEN"
main
# main program is finished
log "-------- FINISH   (main) $PROGIDEN" 
safe_exit
