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
    gsed 's#.*\(https*://\)#\1#' |
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
    gsed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --no-hscroll --tiebreak=begin \
--header='[Google Chrome: bookmark]'" | awk 'BEGIN { FS = "\t" } { print $2 }' |
    xargs open &>/dev/null
}


# Edge
# -----------------------
# meh - browse Microslft Edge history for MacOs
meh() {
  local cols sep
  cols=$((COLUMNS / 3))
  sep='{::}'

  cp -f ~/Library/Application\ Support/Microsoft\ Edge/Default/History /tmp/meh

  sqlite3 -separator $sep /tmp/meh \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
    awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --header='[Microsoft Edge: history]'" |
    gsed 's#.*\(https*://\)#\1#' |
    xargs open &>/dev/null
}

# gcb  - browse Microsoft Edge bookmarks for Macos
meb() {
  which jq >/dev/null 2>&1 || echo "jq is not installed !!!"

  local bookmarks_path=~/Library/Application\ Support/Microsoft\ Edge/Default/Bookmarks
  local jq_script='def ancestors: while(. | length >= 2; del(.[-1,-2])); .
as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path:
 [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse |
join("/") } | .path + "/" + .name + "\t" + .url'

  jq -r "$jq_script" <"$bookmarks_path" |
    gsed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --no-hscroll --tiebreak=begin \
--header='[Google Chrome: bookmark]'" | awk 'BEGIN { FS = "\t" } { print $2 }' |
    xargs open &>/dev/null
}
