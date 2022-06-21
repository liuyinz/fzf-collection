#!/usr/bin/env bash

_fzf_opts=($(echo "${FZF_COLLECTION_OPTS}"))

_fzf_exist() {
  command -v "$@" &>/dev/null
}

## generate fzf header according to command name
_fzf_header() {
  echo $funcstack[2] \
    | perl -pe 's/[_-]/ /g; s/(\w+)/\u\L$1/g; s/^\s+|\s+$//g'
}

# SEE https://stackoverflow.com/a/68093509/13194984
_fzf_underline() {
  printf -- '%s\n' "$1"
  printf -- '▔%.0s' {1..$#1}
}

_fzf_single() {
  fzf "${_fzf_opts[@]}" --header "$(_fzf_underline "$header")" "$@" \
    | perl -lane 'print $F[0]'
}

_fzf_multi() {
  _fzf_single --multi "$@"
}

## generate fzf tmpfile according to command name
_fzf_tmpfile() {
  echo "/tmp/$funcstack[2].lock"
}

_fzf_tmpfile_read() {
  cat <"$tmpfile" | _fzf_multi "$@"
}

_fzf_tmpfile_write() {
  tee "$tmpfile" | _fzf_multi "$@"
}

# SEE https://stackoverflow.com/a/24493085/13194984
## remove related line in tmpfile
_fzf_tmpfile_shift() {
  perl -i -slne '/$f/||print' -- -f="$1" "$tmpfile"
}

_fzf_format() {
  local input rule

  input="$([[ -p /dev/stdin ]] && cat - || return)"

  case $1 in
    manage | registry | pinned)
      rule='printf "%s \x1b[34m%s\x1b[0m\n", $F[0], $F[$#F]'
      ;;
    outdated)
      rule='printf "%s \x1b[34m%s\x1b[0m => \x1b[33m%s\x1b[0m\n", $F[0], $F[1], $F[2]'
      ;;
    *) echo "Argument error: No such $1" && return 0 ;;
  esac

  [ -n "$input" ] && echo "$input" | perl -sane "$rule" | column -s ' ' -t
}

## generate fzf interface according to command name
_fzf_command() {
  local select

  select=$(echo "${cmd[@]}" | perl -pe 's/ /\n/g' | _fzf_single)

  [ -n "$select" ] && "$funcstack[2]-$select"

}
