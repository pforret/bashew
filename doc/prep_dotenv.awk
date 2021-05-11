#!/usr/bin/awk -f
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
/=/ { # skip lines with no equation
  $0=trim($0);
  if(substr($0,1,1) != "#"){ # skip comments
    equal=index($0, "=");
    key=trim(substr($0,1,equal-1));
    val=trim(substr($0,equal+1));
    if(match(val,/^".*"$/) || match(val,/^\047.*\047$/)){
      print key "=" val
    } else {
      print key "=\"" val "\""
    }
  }
}
