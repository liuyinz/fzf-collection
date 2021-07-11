#! /usr/bin/env bash

# Chorme
# -----------------------
# gch - browse chrome history for MacOs
gch() {
  local cols sep
  cols=$((COLUMNS / 3))
  sep='{::}'

  cp -f ~/Library/Application\ Support/Google/Chrome/Default/History /tmp/gch

  sqlite3 -separator $sep /tmp/gch \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
    awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --header='[Google Chrome: history]'" |
    sed 's#.*\(https*://\)#\1#' |
    xargs open &>/dev/null
}

# gcb  - browse chrome Bookmarks for Macos
gcb() {
  which jq >/dev/null 2>&1 || echo "jq is not installed !!!"

  local bookmarks_path=~/Library/Application\ Support/Google/Chrome/Default/Bookmarks
  local jq_script='def ancestors: while(. | length >= 2; del(.[-1,-2])); .
as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path:
 [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse |
join("/") } | .path + "/" + .name + "\t" + .url'

  jq -r "$jq_script" <"$bookmarks_path" |
    sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --no-hscroll --tiebreak=begin \
--header='[Google Chrome: bookmark]'" | awk 'BEGIN { FS = "\t" } { print $2 }' |
    xargs open &>/dev/null
}

    xargs open &>/dev/null
}

# PATH
# ------------------

# [F]ind [P]ath
# list directories in $PATH,press [enter] on an entry to list,press [escape] to go back,[escape] twice to exit completely

fp() {
  local loc
  loc=$(echo "$PATH" | sed -e $'s/:/\\\n/g' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:path]'")

  if [[ -d $loc ]]; then
    rg --files "$loc" | rev | cut -d"/" -f1 | rev |
      eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:exe] => ${loc}' >/dev/null"
    fp
  fi
}

# [F]ind [FP]ath
# list directories in $FPATH,press [enter] on an entry to list,press [escape] to go back,[escape] twice to exit completely
ffp() {
  local loc
  loc=$(echo "$FPATH" | sed -e $'s/:/\\\n/g' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:path]'")

  if [[ -d $loc ]]; then
    rg --files "$loc" | rev | cut -d"/" -f1 | rev | eval \
      "fzf ${FZF_COLLECTION_OPTS} --header='[find:exe] => ${loc}' \
      >/dev/null"
    fp
  fi
}

# PROCESS
# ------------------
# mnemonic: [K]ill [P]rocess
# show output of "ps -ef", use [ab] to select one or multiple entries
# press [enter] to kill selected processes and go back to the process list.
# or press [escape] to go back to the process list. Press [escape] twice to exit completely.

kp() {
  local pid
  pid=$(ps -ef | sed 1d |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[kill:process]'" |
    awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    echo "$pid" | xargs kill -"${1:-9}"
    kp "$@"
  fi
}
