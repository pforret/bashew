#!/bin/bash
readonly this_version="0.1"
readonly orig_repo="bashew"
readonly today=$(date '+%Y-%m-%d')
readonly this_name=$(basename "$0")
this_folder=$(dirname "$0")
if [[ -z "$this_folder" ]] ; then
	# script called without  path specified ; must be in $PATH somewhere
  readonly this_fullpath=$(command -v "$0")
  this_folder=$(dirname "$this_fullpath")
else
  this_folder=$(cd "$this_folder" && pwd)
  readonly this_fullpath="$this_folder/$this_name"
fi
if [[ -z "$1" ]] ; then
cat >&2 <<END
SCRIPT:  $this_name -- by Peter Forret <peter@forret.com> - (c) 2020
PURPOSE: create new bash script from template
USAGE:   $this_name init: initialise this folder/repo -- only if you created a new repo from the template '$orig_repo'
         $this_name new <output.sh>: create a new bash script with name <output.sh>
END
exit 0
fi

ask_question(){
    # ask_question <question> <default>
    local ANSWER
    read -r -p "$1 ($2): " ANSWER
    echo "${ANSWER:-$2}"
}

confirm(){
    # confirm <question> (default = N)
    local ANSWER
    read -r -p "$1 (y/N): " -n 1 ANSWER
    echo " "
    [[ "$ANSWER" =~ ^[Yy]$ ]]
}

get_author_data(){
  git_fullname=$(git config user.name)
  author_fullname=$(ask_question "Author name" "$git_fullname")

  # author email address
  git_email=$(git config user.email)
  author_email=$(ask_question "Author email" "$git_email")

  # author github username
  git_username=$(git config remote.origin.url | cut -d: -f2)
  git_username=$(dirname "$git_username")
  git_username=$(basename "$git_username")
  author_username=$(ask_question "Author username" "$git_username")

  current_directory=$(pwd)
  folder_name=$(basename "$current_directory")
  new_name=$(ask_question "Script name" "$folder_name")

  new_description=$(ask_question "Script description" "This is my script $new_name")
  echo "Author: $author_fullname ($author_username, $author_email)"
  echo "Script: $new_name -- $new_description"
}

replace_in_template(){
  for file in "$@" ; do
    echo "Updating file $file"
    temp_file="$file.temp"
    < "$file" \
      sed "s/author_name/$author_fullname/g" \
    | sed "s/author_username/$author_username/g" \
    | sed "s/author@email.com/$author_email/g" \
    | sed "s/package_name/$new_name/g" \
    | sed "s/package_description/$new_description/g" \
    | sed "s/today/$today/g" \
    > "$temp_file"
    rm -f "$file"
    mv "$temp_file" "$file"
  done
}

if [[ "$1" == "init" ]] ; then
  # remove all the files that are not needed
  # copy all files from template to the root while replacing the variables
  current_directory=$(pwd)
  folder_name=$(basename "$current_directory")
  if [[ "$folder_name" == "$orig_repo" ]] ;  then
    echo "=== WARNING !!!"
    echo "'$this_name init' is meant to be used on a new git repo that was derived from the template '$orig_repo'"
    echo "it is not a good idea to use this on a 'git clone' of the original '$orig_repo' repo"
    echo "for this case, just use '$this_name new <new script name>'"
  else
    replace_in_template $this_folder/template/*
    echo "This script will replace the above values in all relevant files in the project directory and reset the git repository."
    echo $files
    if ! confirm "Modify these files?" ; then
        safe_exit 1
    fi
  fi
  if confirm 'Let this script delete itself (since you only need it once)?' ; then
      echo "Delete $0 !"
      rm -fr "$this_folder/usage"
      rm -fr "$this_folder/docs"
      rm -fr "$this_folder/docs"
      rm -fr "$this_folder/template"
      rm -- "$0"
      rm -- README.md
      mv README.template.md README.md
  fi
  exit 0
fi

if [[ "$1" == "new" ]] ; then

fi
echo "Now run: git commit -a -m 'prepped with $this_name' && git push"