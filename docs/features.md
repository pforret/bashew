# bashew features

## 1. options/flags/usage

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

### param
```   
<action>         : [parameter] action to perform: analyze/convert
<input>          : [parameter] input file (optional)
```
* a 'param' is a text variable. They can be required or optional
* a param has only a long (`action`) name
* the param's value will be available as the `$action` variable in the script.
* params cannot be specified in the .env file

## 2. `.env` support

bashew will auto-detect and import `.env` files. A .env file is just a series of variable definitions (`variable="value"`). They contain presets that are tuned to this user or this machine, and they can contain secrets (passwords, API keys ...) .env files are never added to a git repository.

A bashew-based script `myscript.sh` will look for the following .env files (in this order)
* `[script_installation_path]/.env`
* `[script_installation_path]/myscript.env`
* `[script_installation_path]/.myscript.env`
* `./.env`
* `./myscript.env`
* `./.myscript.env`

This allows for 
* 'global settings' in [script_installation_path] and 'local settings' in the current folder
* separate settings for aliases (symbolic links) of the script. E.g. calling a script as `deploy_dev` could use other default settings than `deploy_prod`

## 3. file system

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

## 4. dependencies
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

## 5. CI/CD

### bash_unit
* unit testing is done with `bash_unit`
* all test scripts are in the `tests` folder
* tests can be run by calling `tests/run_tests.sh`
* tests are also run upon commit/push (see .github/bash_unit.yml)


### Shellcheck
* source code linting/checking is done with `shellcheck`
* shellcheck can be run by calling `shellcheck *.sh`
* shellcheck is also run upon commit/push (see .github/shellcheck.yml)
