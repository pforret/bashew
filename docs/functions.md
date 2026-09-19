# Bashew functions

## Input/Output functions

### IO:alert()
```shell
IO:alert "This file should normally not be empty"
# print alert (to stderr)
```

### IO:announce()
```shell
IO:announce "Now starting conversion ..."
# print announcement and wait 1 second
```

### IO:confirm()
```shell
IO:confirm "Delete intermediate file?"
# ask confirmation, default = N
```

### IO:debug()
```shell
IO:debug "Saving to cache ./cache/file.113.txt"
# print debug text (only if -v/--verbose was specified)
```

### IO:die()
```shell
IO:die "Input is not correctly formatted"
# print error message and stop script
```

### IO:log()
```shell
IO:log "Operation ended after $SECONDS seconds"
# log text to default log file
```

### IO:print()
```shell
IO:print "output: ./export/names.220315.csv"
# show text (except if -q/--quiet was specified)
```

### IO:progress()
```shell
IO:progress "Now processing file #13 ..."
# show text but stay on same line (so next print statement overwrites it)
```

### IO:question()
```shell
IO:question "What is your name?" "(unknown)"
# ask a question and return the answer
name=$(IO:question "What is your name?" "(unknown)")
```

### IO:success()
```shell
IO:success "Some text"
# print text with a success checkmark
```

## OS functions

### Os:beep()
```shell
Os:beep 
# make a sound
```

### Os:busy()
```shell
do_something_slow_in_background &
Os:busy $!  "Doing the slow thing"
# show an animated spinner while process is running
```

### Os:folder()
```shell
Os:folder "/some/folder" 30
# prepare and cleanup a folder: create it if necessary and delete all files older than 30 days
```

### Os:follow_link()
```shell
Os:follow_link "./do_this"
# return actual path of a file, following all symbolic links 
```

### Os:notify()
```shell
Os:notify "Start downloading ..."
# or
Os:notify "Start compiling ..." "Library Compiler"
# send notification to desktop 
```

### Os:require()
```shell
Os:require "ffmpeg"
Os:require "convert" "imagemagick"
Os:require "setver" "basher install pforret/setver"
# quit script when a required program is not installed yet
```

### Os:tempfile()
```shell
Os:tempfile txt
# create filename for temp file that will be deleted when scripts ends
```

## String functions

### Str:ascii()
```shell
Str:ascii "Some text"
# remove accents and diacritics from text
```

### Str:digest()
```shell
<<< "some text" Tool:digest <length:6>
< "some_file.txt" Tool:digest
# calculate hash/digest using MD5 and cut to N chars
```

### Str:lower()
```shell
Str:lower "Some Text"
# convert text to lower case: "INTÉRNÀTIONAL" -> "intérnàtional"
```

### Str:slugify()
```shell
Str:slugify "Some text"
# reduce text to an ASCII filename-ready text
```

### Str:title()
```shell
Str:title "some text"
# convert to title case: "SOME TEXT" -> "Some Text"
```

### Str:trim()
```shell
Str:trim "   some text    "
# trim space from beginning & end of text
```

### Str:upper()
```shell
Str:upper "Some text"
< "some_text.txt" Str:upper
# convert to upper case: "intérnàtional" -> "INTÉRNÀTIONAL"
```

## Tools

### Tool:calc()
```shell
Tool:calc "( 10 / 7 ) * 25"
# calculate
```

### Tool:time()
```shell
Tool:time
# return time as # seconds since 1 jan 1970 with microseconds (e.g.: 1651391010.385)
```

### Tool:pick()
```shell
<<< $'red\ngreen\nblue' Tool:pick "Pick a color:"
< "options.txt" Tool:pick
color=$(ls *.jpg | Tool:pick "Which image?") || echo "nothing chosen"
Tool:pick "Pick a color:" 1 <<< $'red\ngreen\nblue'                # adds "other: ..." to type a free answer
Tool:pick "Pick a color:" "something else..." <<< $'red\ngreen\nblue' # same, with a custom label
Tool:pick "Pick a color:" "" "green" 30 <<< $'red\ngreen\nblue'      # 'green' when no answer within 30 sec
# pick one option from a list: options are read as lines from stdin, the chosen one is written to stdout
# uses fzf if installed, otherwise gum, otherwise a bash-only numbered menu
# parameters: [prompt] [other] [default] [timeout]
#   other  : when non-empty, an extra option with this label is added ("1" = "other: ...");
#            choosing it lets the user type their own answer, which is returned instead
#   default: returned when no choice can be made: on timeout, with -f/--FORCE,
#            or when there is no terminal (cron, CI, ...); defaults to the first option
#   timeout: seconds to wait for a choice before returning the default (0 = wait forever)
# returns 1 (with empty output) when there are no options or the user cancels
```

### Os:has_tty()
```shell
Os:has_tty && IO:confirm "Continue?"
# true when there is a terminal to interact with (false in cron, CI, ...)
```
