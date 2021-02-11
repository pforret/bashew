# bashew features

## 1. input/output

`bashew` offers several functions for reading or sending output from/to the terminal.

`out "some text"`

* used for regular output
* prints a line "some text" to `stdout`
* unless -q/--quiet is specified, then it shows nothing

`debug "some text"`

* prints a line "# some text" to `stderr` in yellow
* only if -v/--verbose is specified

`announce "some text"`

* prints a line "... some text" to `stdout`
* waits 1 second
* used before starting something that might take a while (e.g. creating a ZIP, downloading something, ...), and the text should be read by the user (slows the script down)
* unless -q/--quiet is specified, then it does nothing

`success "some text"`
* prints a line "✔ some text" to `stdout` in green
* unless -q/--quiet is specified, then it does nothing

`progress "some text"`

* prints a line "... some text" to stdout, but with a "\r" (carriage return) instead of a "\n" (line feed) at the end
* this means that the next out/announce/progress will overwrite this line
* used to show progress ("processing file 4 of 554 ...") without filling the whole screen up
* unless -q/--quiet is specified, then it does nothing

`alert "some text"`

* prints an alert "➨ some text" to `stdout` in red
* unless -q/--quiet is specified, then it does nothing

`die "some text"`

* prints a line "✖ some text" to `stdout` in red, unless --quiet has been set
* makes a sound (the 'bell' of your terminal)
* **stops the script**

`confirm "Do you want to remove this file?"`
* default is no/false, unless Y/y is given as an answer
* can be used as `confirm "delete the folder?" && rm -fr "$folder"`
* if `-f`/`--force` was specified, always returns true

`ask days "How many days?" 14`
* get the result in the variable $days

## 2. options/flags/usage

`bashew` only needs one specification of flags, options and parameters, and will use this to do the parsing as well as showing the usage.

This is specified in the beginning of the script as
```
#commented lines will be filtered
flag|h|help|show usage
flag|q|quiet|no output
flag|v|verbose|output more
flag|f|force|do not ask for confirmation (always yes)
option|l|log_dir|folder for log files |$HOME/log/$script_prefix
#option|w|width|width to use|800
#list|u|user|user(s) to execute this for
param|1|action|action to perform: analyze/convert
param|?|input|input file
```

### flag
`-v|--verbose     : [flag] output more [default: off]`

* a 'flag' is a boolean variable. Default is false/off.
* a flag always has a short (`-v`) and a long (`--verbose`) name
* the flag's value will be available as the `$verbose` variable in the script.
* flags can also be set in a .env file (see 3.)

### option
`-l|--log_dir <?> : [option] folder for log files   [default: $HOME/log/normal]`

* an 'option' is a text variable. Default is specified in the option definition (last field).
* an option always has a short (`-l`) and a long (`--logdir`) name
* the option's value will be available as the `$logdir` variable in the script.
* options can also be set in a .env file (see 3.)

### list
`-u|--user <?>    : [list] user(s) to execute this for (array)  [default empty]`

* a 'list' is an array. Default is an empty array ().
* a list always has a short (`-u`) and a long (`--user`) name
* each time the list option is called, the value is added to the array value
* the option's value will be available as the `${user[@]}` array in the script.
* lists can also be set in a .env file (see 3.)

### param
```   
<action>         : [parameter] action to perform: analyze/convert
<input>          : [parameter] input file (optional)
```
* a 'param' is a text variable. They can be required or optional
* a param has only a long (`action`) name
* the param's value will be available as the `$action` variable in the script.
* params cannot be specified in the .env file

## 3. .env support

bashew will auto-detect and import `.env` files. A .env file is just a series of variable definitions (`variable="value"`). They contain presets that are tuned to this user or this machine, and they can contain secrets (passwords, API keys ...) .env files are never added to a git repository.

A bashew-based script `myscript.sh` will look for the following .env files (in this order)
* `[script_installation_path]/.env`
* `[script_installation_path]/myscript.env`
* `./.env`
* `./myscript.env`

This allows for 
* 'global settings' in [script_installation_path] and 'local settings' in the current folder
* separate settings for aliases (symbolic links) of the script. E.g. calling a script as `deploy_dev` could use other default settings than `deploy_prod`

## 4. String manipulation

### lower_case

* convert to lower case
```bash
action="Convert"
action=$(lower_case "$action")
# action="convert"
```

### upper_case

* convert to upper case
```bash
action="Convert"
action=$(upper_case "$action")
# action="CONVERT"
```

### slugify
* convert to text without accents, punctuation, spaces, tabs, limited to 50 chars
* used e.g. to generate valid filenames from unknown text

```bash
employee="Mme. Agnès De L'Evêque"
employee_file="$(slugify "$employee")".txt
# employee_file="mme_agnes_de_leveque.txt"
```

### hash

* calculate SHA1 hash on any input and trim result after N chars
* used to generate values that are +- unique for the given input,

```bash
url="https://github.com/pforret/bashew"
cache_file=.cache/url.$(echo "$url" | hash 10).txt
# cache_file=".cache/url.3bd4e093a5.txt"
```

## 5. file system

### system detection, script resolving

bashew can detect the system you're running on, and the actual folder the script is installed in. This is important if the script needs to find other files (templates, imported files) in the same folder. This is done by recursively resolving symbolic links until the actual real script file is found.

```
# 🔎 Script path: $HOME/.basher/cellar/bin/note 
# 🔎 Symbolic ln: $HOME/.basher/cellar/bin/note -> [$HOME/.basher/cellar/packages/pforret/note/note] 
# 🔎 Symbolic ln: $HOME/.basher/cellar/packages/pforret/note/note -> [./note.sh] 
# 🔎 Actual path: $HOME/.basher/cellar/packages/pforret/note/note.sh 
# 🔎 Shell type : bash - version 5.1.4(1)-release 
# 🔎 System OS  : macOS (Darwin) 11.2 on x86_64 
# 🔎 Package mgt: brew install 
# 🔎 Last modif : Feb 11 10:04:40 2021 
# 🔎 Script ID  : 811 lines / md5: df13c117 
# 🔎 Creation   : 2020-12-14 
# 🔎 Running as : pforret@MacBook-Pro.forret
```

### folder_prep $nb_days
* create the folder if it doesn't exist yet
* delete all files older than $nb_days

### log folder
* there is automatically a log file created at $log_dir/[script_prefix].[YYYYMMDD].log
* log files are deleted after 30 days

### temp folder
* if your script creates temporary (cache) files, they can be saved in the temp folder
* contents of the temp folder are removed after 1 day

## 6. dependencies
bashew scripts can specify the programs/binaries/packages they depend upon and explain the user how to install them if they cannot be found.

This is done in the beginning of the script:
```
ffmpeg
convert|imagemagick
progressbar|basher install pforret/progressbar
```
* if `ffmpeg` cannot be found: tell user to install it by using `brew/apt/yum/... install ffmpeg` (depending on the OS)
* if `convert` cannot be found: tell user to do install by using `brew/apt/yum/... install imagemagick` (depending on the OS)
* if `progressbar` cannot be found: tell user to do install by using `basher install pforret/progressbar` 

## 7. CI/CD

### bash_unit
* unit testing is done with `bash_unit`
* all test scripts are in the `tests` folder
* tests can be run by calling `tests/run_tests.sh`
* tests are also run upon commit/push (see .github/bash_unit.yml)


### Shellcheck
* source code linting/checking is done with `shellcheck`
* shellcheck can be run by calling `shellcheck *.sh`
* shellcheck is also run upon commit/push (see .github/shellcheck.yml)
