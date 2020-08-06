![Bash CI](https://github.com/pforret/bashew/workflows/Bash%20CI/badge.svg) 
![Shellcheck CI](https://github.com/pforret/bashew/workflows/Shellcheck%20CI/badge.svg)
![version](https://img.shields.io/github/v/release/pforret/bashew?include_prereleases)
![activity](https://img.shields.io/github/commit-activity/y/pforret/bashew)
![license](https://img.shields.io/github/license/pforret/bashew)
![repo size](https://img.shields.io/github/repo-size/pforret/bashew)

# bashew
Tool to create new bash scripts

## Usage

### 1. create bash repo
if you want to create a bash script repo, with CI/CD, with README, with tests, with versioning ... 

#### 1.a. create from template in Github

* go to https://github.com/pforret/bashew
* click on 'Use this template'
* choose name

        git clone https://github.com/<you>/<your repo>.git
        cd <your repo>
        bashew.sh init             # will ask for details and iniialise/clean up the repo
        
* and if you have [semver.sh](https://github.com/pforret/semver)

        semver.sh push          # will commit and push new code
        semver.sh new patch     # will set new version to 0.0.1

#### 1.b. git clone into new repo

### 2. create stand-alone bash scripts
if you (regularly) want to create just a script


#### Install this repo

* manually

        git clone https://github.com/pforret/bashew.git
        ln -s bashew/bashew.sh /usr/local/bin
    
* or with basher    

        basher install pforret/bashew
        
#### Create new script

        bashew.sh new <your script>.sh