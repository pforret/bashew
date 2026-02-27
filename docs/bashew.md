# Bashew: Bash Script Creator - Complete Guide for Claude Code

## What is Bashew?

Bashew is a bash script/project scaffolding tool that generates production-ready bash scripts with built-in option parsing, color output, logging, temp file management, and a comprehensive function library. Every generated script is self-contained in a single file with no external dependencies.

**Repository**: [github.com/pforret/bashew](https://github.com/pforret/bashew)
**Version**: See `VERSION.md` (currently 1.22.1)

## Quick Start

### Create a standalone script

```bash
bashew.sh script                        # interactive mode
bashew.sh -f -n "myscript.sh" script    # non-interactive with name
```

This creates a single `.sh` file with the full bashew template embedded.

### Create a project with repo structure

```bash
bashew.sh project                       # interactive mode
bashew.sh -f -n "myproject" project     # non-interactive with name
```

This creates a folder containing:

```
myproject/
├── myproject.sh          # Main script (bashew template)
├── README.md             # With badges and usage section
├── CHANGELOG.md          # Version history
├── VERSION.md            # Semantic version number
├── LICENSE               # MIT license
├── .env.example          # Example environment config
├── .gitignore
├── bitbucket-pipelines.yml
└── .github/workflows/
    ├── bash_unit.yml     # Unit test CI
    └── shellcheck.yml    # Linting CI
```

### Initialize from a cloned bashew template

```bash
git clone https://github.com/pforret/bashew.git myrepo
cd myrepo
./bashew.sh init
```

## Generated Script Architecture

Every bashew-generated script has this structure:

```
┌─────────────────────────────────────────────┐
│  Header: version, author, description       │  ← metadata
├─────────────────────────────────────────────┤
│  Option:config()                            │  ← define flags/options/params
├─────────────────────────────────────────────┤
│  Script:main()                              │  ← main logic with case/esac
├─────────────────────────────────────────────┤
│  Helper functions: do_action1(), etc.       │  ← your implementation
├─────────────────────────────────────────────┤
│  ── DO NOT MODIFY BELOW THIS LINE ──        │
│  Bashew library (IO:, Os:, Str:, Tool:)     │  ← embedded library (~900 lines)
└─────────────────────────────────────────────┘
```

You only edit the top sections. The embedded library at the bottom provides all the utility functions.

## How to Build a Script with Bashew

### Step 1: Define Options in `Option:config()`

This single function defines all your CLI flags, options, and parameters. The same definition drives both parsing and usage text generation.

```bash
function Option:config() {
  grep <<<"
flag|h|help|show usage
flag|Q|QUIET|no output
flag|V|VERBOSE|also show debug messages
flag|f|FORCE|do not ask for confirmation (always yes)
option|L|LOG_DIR|folder for log files |$HOME/log/$script_prefix
option|T|TMP_DIR|folder for temp files|/tmp/$script_prefix
option|w|width|image width for resizing|1200
choice|1|action|action to perform|get,convert,check,env,update
param|?|input|input file/text
" -v -e '^#' -e '^\s*$'
}
```

#### Syntax: `type|short|long|description[|default][|choices]`

| Type | Short | Long | Description | Default | Choices |
|------|-------|------|-------------|---------|---------|
| `flag` | `f` | `FORCE` | do not ask for confirmation | *(0/off)* | |
| `option` | `w` | `width` | image width | `1200` | |
| `list` | `t` | `tag` | add tags | | |
| `param` | `1` | `input` | input file *(required)* | | |
| `param` | `?` | `extra` | extra arg *(optional)* | | |
| `choice` | `1` | `action` | action to perform | | `get,set,check` |

**How each type works:**

- **`flag`** - Boolean. `-f` or `--FORCE` sets `$FORCE=1` (default: `0`). Always has short and long form.
- **`option`** - Text value. `-w 800` or `--width 800` sets `$width=800`. Has a default value.
- **`list`** - Array. `-t foo -t bar` sets `${tag[@]}=("foo" "bar")`. Can be specified multiple times.
- **`param`** - Positional argument. `1` = required, `?` = optional, `n` = multiple.
- **`choice`** - Positional argument validated against a comma-separated list of allowed values.

### Step 2: Implement Actions in `Script:main()`

Use a `case` statement to dispatch on the action parameter:

```bash
function Script:main() {
  IO:log "[$script_basename] $script_version started"

  Os:require "awk"

  case "${action,,}" in   # ${action,,} = lowercase
  get)
    do_get
    ;;
  convert)
    do_convert
    ;;
  check | env)
    Script:check         # built-in: shows all settings
    ;;
  update)
    Script:git_pull      # built-in: git pull for updates
    ;;
  *)
    IO:die "action [$action] not recognized"
    ;;
  esac
  IO:log "[$script_basename] ended after $SECONDS secs"
}
```

**To add a new verb:**
1. Add the verb name to the `choice` line in `Option:config()` (e.g., `get,convert,newverb,check,env,update`)
2. Add a `case` block in `Script:main()`: `newverb) do_newverb ;;`
3. Implement the `do_newverb()` function

### Step 3: Write Helper Functions

Place helper functions between `Script:main()` and the "DO NOT MODIFY" line:

```bash
function do_get() {
  IO:log "get"
  Os:require "curl"
  local url="$input"
  local output_file
  output_file=$(Os:tempfile "html")
  IO:announce "Downloading $url ..."
  curl -s -o "$output_file" "$url"
  IO:success "Downloaded to $output_file"
}

function do_convert() {
  IO:log "convert"
  Os:require "ffmpeg"
  [[ ! -f "$input" ]] && IO:die "Input file [$input] not found"
  IO:print "Converting $input ..."
  # your conversion logic here
}
```

## Real-World Examples

### setver - Semantic Version Manager

[github.com/pforret/setver](https://github.com/pforret/setver) - manages semantic versioning for projects.

```bash
# Option:config excerpt
flag|r|root|do not check if in root folder of repo
flag|C|SKIP_COMPOSER|do not modify composer.json
flag|N|SKIP_NPM|do not modify package.json
option|p|prefix|prefix to use for git tags|v
param|1|action|action to perform: get/check/push/set/new/md/message/auto/autopatch
param|?|input|input text

# Script:main excerpt - many verbs for version management
case "${action,,}" in
get)      get_any_version ;;
check)    check_versions ;;
set)      set_versions "$input" ;;
new)      bump_versions "$input" ;;     # setver new patch/minor/major
push)     commit_and_push ;;
auto)     commit_and_push auto ;;
autopatch) commit_and_push auto ; set_versions patch ;;
esac
```

**Key patterns**: Uses flags to skip specific package managers. Uses `param|?|input` for the optional version/semver-level argument. Many verbs that compose helper functions.

### splashmark - Image Watermarking Tool

[github.com/pforret/splashmark](https://github.com/pforret/splashmark) - downloads photos from Unsplash/Pixabay and adds watermarks, titles, effects.

```bash
# Option:config excerpt - many options for image processing
option|w|width|image width for resizing|1200
option|c|crop|image height for cropping|0
option|i|title|big text to put in center|
option|z|titlesize|font size for title|80
option|e|effect|effect chain: bw/blur/dark/grain/light/median/paint/pixel|
option|g|gravity|title alignment left/center/right|center
option|r|fontcolor|font color to use|FFFFFF
option|U|UNSPLASH_ACCESSKEY|Unsplash access key|
option|P|PIXABAY_ACCESSKEY|Pixabay access key|
choice|1|action|action to perform|unsplash,pixabay,file,folder,url,sizes,check,env,update
param|?|input|URL or search term
param|?|output|output file

# Usage
# splashmark unsplash "mountain lake" → downloads and processes Unsplash photo
# splashmark -i "My Title" file photo.jpg → adds title to local file
```

**Key patterns**: Heavy use of options with defaults for image dimensions, fonts, colors. API keys stored as options (loaded from `.env` files). Two optional params for input/output. Uses `Os:require "convert" "imagemagick"` for ImageMagick dependency.

### ytaudio - YouTube Audio Downloader

[github.com/pforret/ytaudio](https://github.com/pforret/ytaudio) - downloads audio from YouTube with processing.

```bash
# Option:config excerpt
flag|C|CLEAN|cleanup the output file name
flag|I|INFO|lookup metadata and tag file
flag|M|MP3|transcode to high-quality MP3
flag|N|NORMALIZE|normalize output audio
flag|T|TRIM|trim silence from beginning/end
option|D|DOWNLOADER|download binary|yt-dlp
option|F|FORMAT|output audio format|wav
option|O|OUT_DIR|output folder|.
option|Q|QUALITY|audio quality|1
choice|1|action|action to perform|get,search,loop,tracklist,parallel,check,env,update
param|?|input|input URL

# Usage
# ytaudio get "https://youtube.com/watch?v=..."   → download audio
# ytaudio search "artist - song title"             → search and download
# ytaudio -M -N -I search "bohemian rhapsody"      → download as MP3, normalized, with metadata
```

**Key patterns**: Feature flags (`-M`, `-N`, `-T`) toggle processing steps. The downloader binary is configurable via option. Uses `Os:require "$DOWNLOADER"` with a variable. Multiple verbs including `loop` (interactive) and `parallel` (background downloads).

## Function Library Reference

### IO: Functions (Input/Output)

| Function | Description | Affected by |
|----------|-------------|-------------|
| `IO:print "msg"` | Normal output to stdout | Hidden by `-Q/--QUIET` |
| `IO:debug "msg"` | Debug info to stderr | Only shown with `-V/--VERBOSE` |
| `IO:success "msg"` | Success message with checkmark | Hidden by `-Q/--QUIET` |
| `IO:announce "msg"` | Announcement + 1-second pause | Hidden by `-Q/--QUIET` |
| `IO:alert "msg"` | Warning to stderr | Always shown |
| `IO:die "msg"` | Error message + exit script | Always shown |
| `IO:progress "msg"` | Overwriting progress line | Hidden by `-Q/--QUIET` |
| `IO:log "msg"` | Append to `$log_file` | Not affected by flags |
| `IO:confirm "question"` | Ask y/N question | Skipped (=yes) with `-f/--FORCE` |
| `IO:question "q" "default"` | Ask question, return answer | |
| `IO:countdown N "msg"` | Countdown timer | |

### Os: Functions (Operating System)

```bash
Os:require "binary"                          # die if binary not found
Os:require "convert" "imagemagick"           # die if not found, suggest package
Os:require "prog" "pip install prog"         # custom install instruction
# With -f/--FORCE: auto-installs missing binaries instead of dying

Os:folder "/path" 30                         # create folder, cleanup files >30 days
Os:tempfile "txt"                            # create temp file (auto-deleted on exit)
Os:follow_link "./script"                    # resolve symbolic links
Os:notify "message"                          # desktop notification (Linux/macOS)
Os:busy $pid "Processing..."                 # show spinner while PID runs
Os:beep                                      # terminal bell
Os:import_env                                # load .env files
```

### Str: Functions (String Manipulation)

```bash
Str:trim "  text  "                  # → "text"
Str:lower "HELLO"                    # → "hello"
Str:upper "hello"                    # → "HELLO"
Str:ascii "cafe"                     # → "cafe" (remove diacritics)
Str:slugify "Hello World!"           # → "hello-world"
Str:slugify "Hello World!" "_"       # → "hello_world"
Str:title "hello world"              # → "HelloWorld"
Str:title "hello world" "_"          # → "Hello_World"
Str:digest 8 <<< "text"             # → "d3b07384" (MD5 hash, first N chars)
```

### Tool: Functions (Utilities)

```bash
Tool:calc "2 * 3 + 1"               # AWK-based math
Tool:round 3.14159 2                 # → "3.14"
Tool:time                            # current time as float (seconds.microseconds)
Tool:throughput $start_time 100 "files"  # "100 files finished in 3.2 secs"
```

### Script: Functions (Lifecycle)

```bash
Script:check      # display all settings and environment info
Script:exit       # cleanup temp files and exit
Script:git_pull   # update script from git remote
```

## Environment Variables and .env Files

Bashew scripts automatically load `.env` files in this order (later files override earlier):

1. `<script_folder>/.env`
2. `<script_folder>/.<script_prefix>.env`
3. `<script_folder>/<script_prefix>.env`
4. `./.env` *(current directory)*
5. `./.<script_prefix>.env`
6. `./<script_prefix>.env`

Use `.env` files for API keys, credentials, and per-machine configuration:

```bash
# .env
UNSPLASH_ACCESSKEY=your_key_here
SECRET_PASSWORD=abcd1234
SOURCE_FOLDER=$HOME/sources
```

Options defined in `Option:config()` can be overridden in `.env` files. For example, if your script defines `option|w|width|...|1200`, you can set `width=800` in your `.env` file.

## Available Script Variables

Every generated script has these variables available:

```bash
# Script metadata
$script_basename        # "myscript.sh"
$script_prefix          # "myscript"
$script_version         # from VERSION.md or script header
$script_install_folder  # directory containing the script

# System detection
$os_kernel              # Linux / Darwin / MINGW64_NT
$os_name                # Ubuntu / macOS / Windows
$os_machine             # x86_64 / arm64

# Git context (if in a repo)
$git_repo_root          # repo root path
$git_repo_remote        # remote URL

# Paths
$log_file               # current log file path
$tmp_dir                # temp directory (auto-cleaned)
```

## Common Patterns

### Requiring dependencies

```bash
function Script:main() {
  Os:require "awk"
  Os:require "curl"
  Os:require "convert" "imagemagick"
  Os:require "yt-dlp" "brew install yt-dlp"
  # ...
}
```

### Using temp files

```bash
function do_process() {
  local tmpfile
  tmpfile=$(Os:tempfile "json")     # auto-deleted on script exit
  curl -s "$url" > "$tmpfile"
  # process $tmpfile ...
}
```

### Asking for confirmation

```bash
function do_delete() {
  if IO:confirm "Delete all files in $folder?" ; then
    rm -rf "$folder"/*
    IO:success "Files deleted"
  fi
  # With -f/--FORCE flag, confirmation is skipped (auto-yes)
}
```

### Processing with progress

```bash
function do_batch() {
  local count=0
  for file in "$input"/*.txt; do
    ((count++))
    IO:progress "Processing file $count: $(basename "$file")"
    # process $file ...
  done
  IO:success "Processed $count files"
}
```

### Composing actions

```bash
# In Option:config():
# choice|1|action|...|download,process,all,check,env,update

case "${action,,}" in
download)  do_download ;;
process)   do_process ;;
all)
  do_download
  do_process
  ;;
esac
```

## Testing

Bashew projects use [bash_unit](https://github.com/pgrange/bash_unit) for testing.

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test file
bash_unit tests/test_basic.sh
```

Test files use these assertions:

```bash
test_script_runs() {
  assert "./myscript.sh -h"
}

test_output_correct() {
  assert_equals "expected" "$(./myscript.sh get input.txt)"
}

test_bad_input_fails() {
  assert_fails "./myscript.sh get nonexistent.txt"
}
```

Install bash_unit:

```bash
# macOS
brew install bash_unit

# Other: see https://github.com/pgrange/bash_unit
```

## CI/CD

Generated projects include GitHub Actions workflows:

- **`.github/workflows/shellcheck.yml`** - Runs shellcheck on all `.sh` files
- **`.github/workflows/bash_unit.yml`** - Runs bash_unit tests on Ubuntu and macOS

Both run on push and pull requests. Skip CI with `[skip ci]` in your commit message.

## Version Management

Version is determined in this order of priority:

1. `VERSION.md` file (if present)
2. `script_version` variable in the script header
3. Git tags

Use [pforret/setver](https://github.com/pforret/setver) for semantic versioning:

```bash
setver new patch      # 0.0.0 → 0.0.1
setver new minor      # 0.0.1 → 0.1.0
setver new major      # 0.1.0 → 1.0.0
setver push           # commit + push + tag
```

## Template Placeholders

When bashew generates a script, these placeholders in `template/script.sh` are replaced:

| Placeholder | Replaced with |
|---|---|
| `author_name` | Author's full name |
| `author_username` | GitHub username |
| `author@email.com` | Author's email |
| `package_name` | Script/project name |
| `package_description` | Description text |
| `meta_today` | Creation date (YYYY-MM-DD) |
| `meta_year` | Creation year |
| `bashew_version` | Bashew version used |

Author data is collected from environment variables (`BASHEW_AUTHOR_FULLNAME`, `BASHEW_AUTHOR_EMAIL`, `BASHEW_AUTHOR_USERNAME`), git config, or interactive prompts.

## Strict Mode

All generated scripts run with:

```bash
set -uo pipefail
IFS=$'\n\t'
```

- `-u` - Treat unset variables as errors
- `-o pipefail` - Pipeline fails if any command fails
- Custom `IFS` - Prevents word-splitting surprises

Note: `-e` is intentionally omitted to allow `[[ ... ]]` testing without unexpected exits.

## Error Handling

Scripts trap `INT`, `TERM`, and `EXIT` signals to display the error location (function name and line number) and run cleanup (deleting temp files).
