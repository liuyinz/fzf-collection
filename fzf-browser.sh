#! /usr/bin/env bash

# [B]rowser [H]isroty [F]zf
# ------------------
# Used for firefox, microsoft edge and google chrome on MacOs
bhf() {
  which sqlite3 >/dev/null 2>&1 || echo "sqlite3 is not installed !!!"
  local prefix_path default_browser temp_dir history_file cols sep sql

  prefix_path="$HOME/Library/Application Support"

  # SEE https://stackoverflow.com/a/66026925/13194984
  default_browser=$(plutil -p ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist |
    grep 'https' -b3 |
    awk 'NR==3 {split($4, arr, "\""); print arr[2]}' |
    cut -d'.' -f3)

  temp_dir=/tmp/"$default_browser"
  mkdir -p "$temp_dir"

  cols=$((COLUMNS / 3))

  case $default_browser in
  chrome)
    history_file="$prefix_path/Google/Chrome/Default/History"
    sql="select substr(title, 1, $cols), url from urls order by last_visit_time desc"
    ;;
  edgemac)
    history_file="$prefix_path/Microsoft Edge/Default/History"
    sql="select substr(title, 1, $cols), url from urls order by last_visit_time desc"
    ;;
  firefox)
    # SEE https://www.foxtonforensics.com/browser-history-examiner/firefox-history-location
    firefox_profile=$(grep "Default=Profiles" "$prefix_path"/Firefox/profiles.ini |
      cut -d'/' -f2)
    history_file="$prefix_path/Firefox/Profiles/$firefox_profile/places.sqlite"
    sql="select substr(title, 1, $cols), url from moz_places order by last_visit_date desc"
    ;;
  safari)
    history_file="$HOME/Library/Safari/History.db"
    sql="select substr(V.title, 1, $cols), I.url from history_visits V left join
history_items I on V.history_item = I.id order by visit_time desc"
    ;;
  esac

  if ! cmp -s "$history_file" "$temp_dir"/history; then
    cp -f "$history_file" "$temp_dir"/history
  fi

  sep='{::}'

  sqlite3 -separator $sep "$temp_dir"/history "$sql" |
    awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
    eval "fzf $FZF_COLLECTION_OPTS --ansi --header='history : [$default_browser]'" |
    sed 's#.*\(https*://\)#\1#' |
    xargs open &>/dev/null
}

# [B]rowser [B]ookmark [F]zf
# ------------------
# Used for firefox, microsoft edge and google chrome on MacOs
bbf() {
  which jq >/dev/null 2>&1 || echo "jq is not installed !!!"

  local prefix_path default_browser bookmark_file temp_dir

  prefix_path="$HOME/Library/Application Support"

  # SEE https://stackoverflow.com/a/66026925/13194984
  default_browser=$(
    plutil -p ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist |
      grep 'https' -b3 |
      awk 'NR==3 {split($4, arr, "\""); print arr[2]}' |
      cut -d'.' -f3
  )

  temp_dir=/tmp/"$default_browser"
  mkdir -p "$temp_dir"

  case $default_browser in
  chrome)
    bookmark_file="$prefix_path/Google/Chrome/Default/Bookmarks"
    ;;
  edgemac)
    bookmark_file="$prefix_path/Microsoft Edge/Default/Bookmarks"
    ;;
  firefox)
    firefox_profile=$(grep "Default=Profiles" "$prefix_path"/Firefox/profiles.ini | cut -d'/' -f2)
    bookmark_file="$prefix_path/Firefox/Profiles/$firefox_profile/places.sqlite"
    ;;
    #  TODO support for Sarari
    # safari)
    #   bookmark_file="$HOME/Library/Sarari/Bookmarks.plist"
    #   ;;
  esac

  if ! cmp -s "$bookmark_file" "$temp_dir"/bookmark; then
    cp -f "$bookmark_file" "$temp_dir"/bookmark
  fi

  case $default_browser in
  chrome | edgemac)
    local jq_script='def ancestors: while(. | length >= 2; del(.[-1,-2])); .
as $in | paths(.url?) as $key | $in | getpath($key) | {name,url, path:
 [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse |
join("/") } | .path + "/" + .name + "\t" + .url'

    jq -r "$jq_script" <"$temp_dir"/bookmark |
      sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' |
      eval "fzf $FZF_COLLECTION_OPTS --ansi --no-hscroll --tiebreak=begin \
--header='bookmark : $default_browser'" | awk 'BEGIN { FS = "\t" } { print $2 }' |
      xargs open &>/dev/null
    ;;
  firefox)
    local cols=$((COLUMNS / 3))
    local sep='{::}'
    local sql="select substr(B.title, 1, $cols), P.url from moz_bookmarks B left join
moz_places P on B.fk = P.id order by visit_count desc"

    sqlite3 -separator $sep "$temp_dir"/bookmark "$sql" |
      awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
      eval "fzf $FZF_COLLECTION_OPTS --ansi --header='bookmark : [$default_browser]'" |
      sed 's#.*\(https*://\)#\1#' |
      xargs open &>/dev/null
    ;;
    # safari)
    #   ;;
  esac
}
