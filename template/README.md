![bash_unit CI](https://github.com/author_username/package_name/workflows/bash_unit%20CI/badge.svg)
![Shellcheck CI](https://github.com/author_username/package_name/workflows/Shellcheck%20CI/badge.svg)
![GH Language](https://img.shields.io/github/languages/top/author_username/package_name)
![GH stars](https://img.shields.io/github/stars/author_username/package_name)
![GH tag](https://img.shields.io/github/v/tag/author_username/package_name)
![GH License](https://img.shields.io/github/license/author_username/package_name)
[![basher install](https://img.shields.io/badge/basher-install-white?logo=gnu-bash&style=flat)](https://www.basher.it/package/)

# package_name

package_description

## 🔥 Usage

```
Program : package_name  by author@email.com
Version : v0.0.1 (Apr 22 16:07:13 2023)
Purpose : package_description
Usage   : package_name [-h] [-q] [-v] [-f] [-l <log_dir>] [-t <tmp_dir>] <action>
Flags, options and parameters:
    -h|--help        : [flag] show usage [default: off]
    -q|--quiet       : [flag] no output [default: off]
    -v|--verbose     : [flag] also show debug messages [default: off]
    -f|--force       : [flag] do not ask for confirmation (always yes) [default: off]
    -l|--log_dir <?> : [option] folder for log files   [default: /Users/pforret/log/script]
    -t|--tmp_dir <?> : [option] folder for temp files  [default: /tmp/script]
    <action>         : [choice] action to perform  [options: action1,action2,check,env,update]
                                  
### TIPS & EXAMPLES
* use package_name action1 to ...
  package_name action1
* use package_name action2 to ...
  package_name action2
* use package_name check to check if this script is ready to execute and what values the options/flags are
  package_name check
* use package_name env to generate an example .env file
  package_name env > .env
* use package_name update to update to the latest version
  package_name update
* >>> bash script created with pforret/bashew
* >>> for bash development, also check out pforret/setver and pforret/progressbar
```

## ⚡️ Examples

```bash
> package_name -h 
# get extended usage info
> package_name env > .env
# create a .env file with default values
```

## 🚀 Installation

with [basher](https://github.com/basherpm/basher)

	$ basher install author_username/package_name

or with `git`

	$ git clone https://github.com/author_username/package_name.git
	$ cd package_name

## 📝 Acknowledgements

* script created with [bashew](https://github.com/pforret/bashew)

&copy; meta_year author_name