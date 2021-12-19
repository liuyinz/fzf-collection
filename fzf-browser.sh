#! /usr/bin/env bash

if [ -z "$FZF_COLLECTION_BROWSER" ]; then
  # SEE https://stackoverflow.com/a/66026925/13194984
  FZF_COLLECTION_BROWSER=$(
    plutil -p ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist \
      | grep 'https' -b3 \
      | awk 'NR==3 {split($4, arr, "\""); print arr[2]}' \
      | cut -d'.' -f3
  )
fi

prefix_path="$HOME/Library/Application Support"

declare -A asso_browser

case $FZF_COLLECTION_BROWSER in
  chrome)
    asso_browser=(
      [name]="Google Chrome"
      [tmp]="/tmp/chrome"
      [history]="$prefix_path/Google/Chrome/Default/History"
      [bookmark]="$prefix_path/Google/Chrome/Default/Bookmarks"
      [history_sql]="select substr(title, 1, $((COLUMNS / 3))), url from urls order by last_visit_time desc"
    )
    ;;
  edgemac)
    asso_browser=(
      [name]="Microsoft Edge"
      [tmp]="/tmp/edgemac"
      [history]="$prefix_path/Microsoft Edge/Default/History"
      [bookmark]="$prefix_path/Microsoft Edge/Default/Bookmarks"
      [history_sql]="select substr(title, 1, $((COLUMNS / 3))), url from urls order by last_visit_time desc"
    )
    ;;
  firefox)
    # SEE https://www.foxtonforensics.com/browser-history-examiner/firefox-history-location
    _profile=$(grep "Default=Profiles" "$prefix_path/Firefox/profiles.ini" | cut -d'/' -f2)
    asso_browser=(
      [name]="Firefox"
      [tmp]="/tmp/firefox"
      [history]="$prefix_path/Firefox/Profiles/$_profile/places.sqlite"
      [bookmark]="$prefix_path/Firefox/Profiles/$_profile/places.sqlite"
      [hisroty_sql]="select substr(title, 1, $((COLUMNS / 3))), url from moz_places order by last_visit_date desc"
    )
    ;;
  safari)
    asso_browser=(
      [name]="Safari"
      [tmp]="/tmp/safari"
      [history]="$HOME/Library/Safari/History.db"
      [bookmark]="$HOME/Library/Safari/Bookmarks.plist"
      [history_sql]="select substr(V.title, 1, $((COLUMNS / 3))), I.url from history_visits V left join history_items I on V.history_item = I.id order by visit_time desc"
    )
    ;;
esac

mkdir -p "${asso_browser[tmp]}"

# [B]rowser [H]isroty [F]zf
# ------------------
# Used for firefox, microsoft edge and google chrome on MacOS
bhf() {
  which sqlite3 >/dev/null 2>&1 || echo "sqlite3 is not installed !!!"
  local sep
  sep='::'

  if ! cmp -s "${asso_browser[history]}" "${asso_browser[tmp]}/history"; then
    cp -f "${asso_browser[history]}" "${asso_browser[tmp]}/history"
  fi

  # SEE https://superuser.com/a/555520
  sqlite3 -separator $sep "${asso_browser[tmp]}/history" "${asso_browser[history_sql]}" \
    | awk -F $sep '{printf "\x1b[36m%-'$((COLUMNS / 3))'.'$((COLUMNS / 3))'s\x1b[m  %s\n", $1, $2}' \
    | uniq -u \
    | _fzf_multi --ansi --header "$(_headerf "History: $FZF_COLLECTION_BROWSER")" \
    | sed 's#.*\(https*://\)#\1#' \
    | xargs -r open -a "${asso_browser[name]}" &>/dev/null
}

# [B]rowser [B]ookmark [F]zf
# ------------------
# Used for firefox, microsoft edge and google chrome on MacOs
bbf() {

  if ! cmp -s "${asso_browser[bookmark]}" "${asso_browser[tmp]}/bookmark"; then
    cp -f "${asso_browser[bookmark]}" "${asso_browser[tmp]}/bookmark"
  fi

  case $FZF_COLLECTION_BROWSER in
    chrome | edgemac)
      which jq >/dev/null 2>&1 || echo "jq is not installed !!!"

      local jq_script='
def ancestors: while(. | length >= 2; del(.[-1,-2]));
. as $in |
paths(.url?) as $key |
$in |
getpath($key) |
{name,url, path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] |
reverse |
join("/") } |
 .path + "/" + .name + "\t" + .url'

      jq -r "$jq_script" <"${asso_browser[tmp]}/bookmark" \
        | sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' \
        | _fzf_multi --ansi --no-hscroll --tiebreak=begin \
          --header "$(_headerf "Bookmark: $FZF_COLLECTION_BROWSER")" \
        | awk 'BEGIN { FS = "\t" } { print $2 }' \
        | xargs -r open -a "${asso_browser[name]}" &>/dev/null
      ;;

    safari)
      local jq_script='
def ancestors: while(. | length >= 3; del(.[-1,-2,-3]));
. as $in |
paths(.string?) | select(.[-2:]==["dict",3] and .[-5:-3]==["array","dict"]) |
del(.[-1,-2]) |
. as $key |
$in |
getpath($key) |
{name: .dict[3].string,
url: .string[0],
path: [$key | ancestors as $a | $in | getpath($a) | .string[0]?]
| del(.[0]) |
reverse |
join("/")} |
.path + "/" + .name + "\t" + .url'

      plutil -convert xml1 "${asso_browser[tmp]}/bookmark" -o - | xq -r "$jq_script" \
        | sed -E $'s/(.*)\t(.*)/\\1\t\x1b[36m\\2\x1b[m/g' \
        | _fzf_multi --ansi --no-hscroll --tiebreak=begin \
          --header "$(_headerf "Bookmark: $FZF_COLLECTION_BROWSER")" \
        | awk 'BEGIN { FS = "\t" } { print $2 }' \
        | xargs -r open -a "${asso_browser[name]}" &>/dev/null
      ;;

    firefox)
      local sep cols
      sep='::'
      cols=$((COLUMNS / 3))
      # SEE https://apple.stackexchange.com/a/322883
      local sql="select substr(B.title, 1, $cols), P.url from moz_bookmarks B left join
moz_places P on B.fk = P.id order by visit_count desc"
      sqlite3 -separator $sep "${asso_browser[tmp]}/bookmark" "$sql" \
        | awk -F $sep '{printf "%-'"$cols"'s  \x1b[36m%s\x1b[m\n", $1, $2}' \
        | _fzf_multi --ansi \
          --header "$(_headerf "Bookmark: $FZF_COLLECTION_BROWSER")" \
        | sed 's#.*\(https*://\)#\1#' \
        | xargs -r open -a "${asso_browser[name]}" &>/dev/null
      ;;
  esac
}
