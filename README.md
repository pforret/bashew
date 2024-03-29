[![Shellcheck CI](https://github.com/pforret/bashew/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/pforret/bashew/actions/workflows/shellcheck.yml)
[![bash_unit CI](https://github.com/pforret/bashew/actions/workflows/bash_unit.yml/badge.svg)](https://github.com/pforret/bashew/actions/workflows/bash_unit.yml)
[![version](https://img.shields.io/github/v/tag/pforret/bashew)](https://github.com/pforret/bashew/tags)
[![version](https://img.shields.io/github/v/release/pforret/bashew)](https://github.com/pforret/bashew/releases)

Part of [![part of Bashful Scripting network](https://img.shields.io/badge/bashful-scripting-orange)](https://blog.forret.com/portfolio/bashful/) network
/
Install with [![basher install](https://img.shields.io/badge/basher-install-white?logo=gnu-bash&style=flat)](https://www.basher.it/package/)

# bashew.sh

![Bashew Logo](assets/bashew.jpg)

bash script / project creator

## ⏳ TL;DR

to create a new stand-alone **SCRIPT** (just a xyz.sh script), with option parsing, color output (cf `1.`)

        bashew.sh script
    
to create a new standalone script **PROJECT** (in a folder, with README) (cf `2.`)

        bashew.sh project

to initialize a bashew-based **REPO** with CI/CD you just cloned (cf `3.`)

        bashew init
     
## 🎯 Features

### Self-contained
* all code contained in 1 single file (no external dependencies)
* comes with `README.md`, `CHANGELOG.md`, ... markdown files
* edit only `Script:main()` function and subroutines in beginning of script, all template code is at the end of the script

### Option parsing
* definition of flags/options/parameters in 1 place only
* automatic creation of usage text based on definition above
* short/long option parsing, based on definition above
* option `--lorem [value]` is available inside the script as `$lorem`

### [function library](doc/functions.md)
* `IO:` functions for IO, with intelligent color usage (not when output is piped) (e.g. `IO.success`, `IO.die`)
* `Str:` functions for string manipulation (e.g `Str:lower`, `Str:digest`)
* `Os:` functions for e.g. required program checking (e.g. `Os:require convert imagemagick`)

### [batteries included](doc/features.md)
* read multiple `.env` configuration files
* predefined `--quiet` (no output) and `--verbose` (more output) modes
* folder for temporary files (with automatic cleanup)
* folder for log files (with automatic cleanup)
* correct determination of script installation folder (resolve symbolic links)
* easy CI/CD for Github (with shellcheck)

## 🔥 Usage

```ini
Program: bashew 1.18.2 by peter@forret.com
Updated: May  1 16:49:18 2022
Description: package_description
Usage: bashew [-h] [-q] [-v] [-f] [-l <log_dir>] [-t <tmp_dir>] [-n <name>] <action>
Flags, options and parameters:
    -h|--help        : [flag] show usage [default: off]
    -q|--quiet       : [flag] no output [default: off]
    -v|--verbose     : [flag] output more [default: off]
    -f|--force       : [flag] do not ask for confirmation (always yes) [default: off]
    -l|--log_dir <?> : [option] folder for debug files   [default: /Users/pforret/log/bashew]
    -t|--tmp_dir <?> : [option] folder for temp files  [default: /tmp/bashew]
    -n|--name <?>    : [option] name of new script or project
    <action>         : [parameter] action to perform: script/project/init/update
```

### 1. create new bash script (without repo)
```shell
bashew.sh script                    # will interactively ask for author & script details
bashew.sh -f script                 # will create new script with random name
bashew.sh -f -n "../list.sh" script # will create new script ../list.sh
```

Example:
```console
$ bashew script
⏳  1. first we need the information of the author
Author full name         (pforret) > Peter Forret
Author email             (peter@forret.com) > 
Author (github) username (pforret) > 
⏳  2. now we need the path and name of this new script/repo
Script name (./bespoke_bunny.sh) > 
⏳  3. give some description of what the script should do
Script description (This is my script bespoke_bunny) > process log files
⏳  Creating script ./bespoke_bunny.sh ...
./bespoke_bunny.sh

$ bashew -f script 
⏳  Creating script ./mediums_appease.sh ...
./mediums_appease.sh
```

### 2. create new bash project folder/repo (with README.md, CI/CD)
```console
$ bashew project               # will interactively ask for author & script details
or
$ bashew -f project            # will create new project with random name
or
$ bashew -f -n "tango" project # will create new project in folder "tango"
```

Example:
```console
$ bashew -f project
⏳  Creating project ./bounden_brawled ...
CHANGELOG.md README.md VERSION.md LICENSE .gitignore .env.example bounden_brawled.sh bitbucket-pipelines .github  
✅  next step: 'cd ./bounden_brawled' and start scripting!
```

### 3. create a bash script repo, with CI/CD, with README, with tests, with versioning ... 

* on [github.com/pforret/bashew](https://github.com/pforret/bashew), click on '**Use this template**'
* then clone your new repo
```console
$ git clone https://github.com/<you>/<your repo>.git
$ cd <your repo>
$ ./bashew.sh init             # will ask for details and initialise/clean up the repo
```

#### and then, if you have [setver.sh](https://github.com/pforret/setver):
```console
$ setver push          # will commit and push new code
$ setver new patch     # will set new version to 0.0.1
$ setver set 1.0.0     # when your first working version is committed
```
  
### 4. git clone into new repo
```console
$ git clone --depth=1 https://github.com/pforret/bashew.git <newname>
$ cd <newname>
$ ./bashew.sh init             # will ask for details and iniialise/clean up the repo
```

## 🚀 Installation

* manually
````console
$ git clone https://github.com/pforret/bashew.git
$ ln -s bashew/bashew.sh /usr/local/bin
````
    
* or with [basher](https://github.com/basherpm/basher) package manager
  [![basher install](https://img.shields.io/badge/basher-install-white?logo=gnu-bash&style=flat)](https://basher.gitparade.com/package/)

````console
$ basher install pforret/bashew
````

## 🦪 Built with Bashew

* [bumpkeys](https://github.com/pforret/bumpkeys): upgrade your SSH keys for better security
* [crontask](https://github.com/pforret/crontask): call scripts or URLs from a crontab file, with optional logging and webhook upon success/failure
* [jekyll_taxonomy](https://github.com/pforret/jekyll_taxonomy): Generate tag and category pages for Jekyll static sites
* [m1_homebrew](https://github.com/pforret/m1_homebrew): Install homebrew in native mode on Apple MacOS ARM
* [mkdox](https://github.com/pforret/mkdox): create and run Mkdocs Material websites using Docker image
* [netcheck](https://github.com/pforret/netcheck): test network: interfaces, gateway, router, internet
* [note](https://github.com/pforret/note): Manage your notes, todo, ... with this nifty script
* [pa](https://github.com/pforret/pa): like "php artisan" but more intelligent (use optimal PHP version for the project
* [progressbar](https://github.com/pforret/progressbar): Easy, clever progress bar for (bash) scripts
* [rexec](https://github.com/pforret/rexec): repeat a command and be alerted when the output changes
* [saild](https://github.com/pforret/saild): Start up your Laravel Sail dev setup in one go - Docker, Browser, Shell
* [screenshots](https://github.com/pforret/screenshots): Let GitHub automatically make 📸 screenshots of all your websites
* [setver](https://github.com/pforret/setver): Easy semver tool -- get/set git version (one-line superfast git commit)
* [shaml](https://github.com/pforret/shaml): Read YAML files inside bash scripts
* [shini](https://github.com/pforret/shini): Read INI files inside bash scripts
* [shlaunch](https://github.com/pforret/shlaunch): Launch desktop/GUI apps from CLI (e.g. Chrome, PHPStorm, Photoshop ...)
* [shlorem](https://github.com/pforret/shlorem): Lorem Ipsum generator for the command line
* [shmixcloud](https://github.com/pforret/shmixcloud): download Mixcloud shows and add album art to m4a files
* [shoarma](https://github.com/pforret/shoarma): Static Image Site Generator - make e.g. Jekyll posts from folder of images
* [shtext](https://github.com/pforret/shtext): Text manipulation in bash, by always using the fastest method
* [shwiki](https://github.com/pforret/shwiki): Wikipedia CLI in bash
* [shwordle](https://github.com/pforret/shwordle): Wordle-clone with variable # of letters and multiple languages
* [splashmark](https://github.com/pforret/splashmark): download/create (unsplash/pixabay/replicate) pics and resize/add effects/add attribution/watermark
* [teams-cli](https://github.com/cinemapub/teams-cli): Send messages to MS Teams channels from CLI
* [xkcd](https://github.com/pforret/xkcd): View a XKCD comic in your console/TTY


## 🙏 Acknowledgements

* [bash_unit](https://github.com/pgrange/bash_unit): bash unit testing enterprise edition framework (used for CI/CD)
* [shellcheck](https://github.com/koalaman/shellcheck): a static analysis tool for shell scripts (used for CI/CD)
* [bash-boilerplate (2012)](https://github.com/oxyc/bash-boilerplate) on which I based my [bash-boilerplate (2020)](https://github.com/pforret/bash-boilerplate) which eventually became this [bashew](https://github.com/pforret/bashew)
* Bash documentation from [Google](https://google.github.io/styleguide/shellguide.html), [BashPitfalls](https://mywiki.wooledge.org/BashPitfalls), [Microsoft](https://github.com/microsoft/code-with-engineering-playbook/blob/master/code-reviews/recipes/Bash.md)

## 🤔 What's that name? Bashew?
* derived from 'bash new'
* rhymes with cashew

## Stargazers over time

[![Stargazers over time](https://starchart.cc/pforret/bashew.svg)](https://starchart.cc/pforret/bashew)
