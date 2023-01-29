#!/usr/bin/env bash

proxyf_temp="$HOME/.cache/proxyf/pid-$$"

declare -a proxyf_shell_env=(
  "http_proxy"
  "https_proxy" "HTTPS_PROXY"
  "all_proxy" "ALL_PROXY"
  "rsync_proxy" "RSYNC_PROXY"
  "ftp_proxy" "FTP_PROXY"
)

declare -a proxyf_array=("None")
while IFS='' read -r line; do
  proxyf_array+=("$line")
done < <(echo "$PROXYF_URLS" | perl -pe 's/,/\n/g')

_proxyf_init() {
  mkdir -p -- "$(dirname "$proxyf_temp")"

  if [ ! -f "$proxyf_temp" ]; then
    printf "shell None\ngit None\nnpm None\nyarn None" >"$proxyf_temp"
  fi
}

_proxyf_format() {
  perl -ane '
my $sign = "\x1b[0m";
if ($F[1] !~ /^None.*/m) {$sign = ($F[1] =~ /^http.*/m ? "\x1b[32m" : "\x1b[35m")};
printf "%s %s%s\x1b[0m\n", $F[0], $sign, $F[1]' "$proxyf_temp" \
    | column -t -s ' '
}

_proxyf_update() {
  echo "$1 switch to $2"
  perl -i -slpe 's/^\Q$f\E.*$/$f $u/m' -- -f="$1" -u="$2" "$proxyf_temp"
}

_proxyf_toggle_shell() {
  for env in "${proxyf_shell_env[@]}"; do
    if [[ $1 != "None" ]]; then
      export "$env"="$1"
    else
      unset "$env"
    fi
  done
}

_proxyf_toggle_git() {
  local proc=${1/socks/socks5}

  if command -v git >/dev/null; then
    if [[ $proc != "None" ]]; then
      git config --global http.proxy "$proc"
    else
      git config --global --unset http.proxy
    fi
  fi
}

_proxyf_toggle_npm() {
  if command -v npm >/dev/null; then
    if [[ $1 != "None" ]]; then
      npm config set proxy "$1"
      npm config set https-proxy "$1"
    else
      npm config delete proxy
      npm config delete https-proxy
    fi
  fi
}

_proxyf_toggle_yarn() {
  if command -v yarn >/dev/null; then
    if [[ $1 != "None" ]]; then
      yarn config set proxy "$1"
      yarn config set https-proxy "$1"
    else
      yarn config delete proxy
      yarn config delete https-proxy
    fi
  fi
}

proxyf-switch() {
  local header

  header=$(_fzf_header)

  select=$(
    _proxyf_format \
      | _fzf_read --multi \
      | perl -lane 'print $F[0]'
  )

  if [ -n "$select" ]; then

    url=$(echo "${proxyf_array[@]}" | perl -pe 's/ /\n/g' | _fzf_read)

    if [ -n "$url" ]; then
      for opt in $(echo "$select"); do
        "_proxyf_toggle_$opt" "$url"
        _proxyf_update "$opt" "$url"
      done
    else
      return 0
    fi

  else
    echo "Switch cancel" && return 0
  fi

  proxyf-switch

}

proxyf-add() {
  local header new_type new_proxy

  header=$(_fzf_header)
  new_type=$(printf "http\nsocks" | _fzf_read)

  if [ -n "$new_type" ]; then
    echo -n "[address:port] ${new_type}://"
    read -r new_proxy
    if [[ $new_proxy =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+$ ]]; then
      # TODO remove duplicate words in string with perl
      proxyf_array=(
        $(
          echo "${proxyf_array[@]}" "${new_type}://${new_proxy}" \
            | perl -pe 's/ /\n/g' \
            | perl -ne '!$h{$_}++ && print'
        ))
    fi
  fi

  echo "${proxyf_array[@]}" | perl -pe 's/ /\n/g' | _fzf_read

}

proxyf() {
  _proxyf_init

  local header opt

  header=$(_fzf_header)
  opt=("switch" "add")

  _fzf_command
}
