#!/usr/bin/env bash

_gitf_sha() {
  local commit

  commit=$(
    git log --pretty=oneline --abbrev-commit \
      | _fzf_single \
      | perl -lane 'print $F[0]'
  )

  echo "$commit"
}

_gitf_browse() {
  local remote url dir

  dir=${1:-$PWD}
  remote=$(git -C "$dir" config remote.origin.url)

  if [ -n "$remote" ]; then
    url=$(echo "$remote" | perl -pe 's|git@(.*):(.*)|https://$1/$2|;s|(.*).git/?$|$1|')
    echo "Open in browser: $url" && open "$url"
  else
    echo "Error! \"$dir\" isn't a git repo!"
  fi
}

gitf-commit() {
  local commit
  commit=$(_gitf_sha)

  if [ -n "$commit" ]; then
    git checkout "$commit"
  fi
}

gitf-submodule() {
  local module subcmd header

  header=$(_fzf_header)
  # SEE https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository#comment84215697_12641787
  module=$(
    git config --file \
      "$(git rev-parse --show-toplevel)/.gitmodules" --get-regexp '\.path$' \
      | perl -lane 'print $F[1]' \
      | sort -f \
      | _fzf_multi
  )

  if [ -n "$module" ]; then
    # shellcheck disable=SC2028
    subcmd=$(
      echo "update-remote\ndelete\nhomepage\ndir\ninit\ndeinit\nupdate-init" \
        | _fzf_single
    )

    for i in $(echo "$module"); do
      f="$(git rev-parse --show-toplevel)"/$i
      case $subcmd in
        update-remote)
          echo "$i ..."
          git submodule update --remote "$f"
          ;;
        delete)
          git delete-submodule --force "$f" >/dev/null 2>&1
          ;;
        homepage)
          _gitf_browse "$f"
          ;;
        dir)
          cd "$f" || exit
          ;;
        update-init)
          echo "$i ..."
          git submodule update --init "$f"
          ;;
        deinit)
          git submodule deinit --force "$f"
          ;;
        init)
          git submodule init "$f"
          ;;
      esac
    done
  fi
}

gitf-stash() {
  local inst header
  header=$(_fzf_header)
  inst=$(
    git stash list \
      | _fzf_single \
      | perl -F':' -lne 'print $F[1]' \
      | tac
  )

  if [ -n "$inst" ]; then
    local subcmd

    # shellcheck disable=SC2028
    subcmd=$(echo "pop\nbranch\ndrop\napply\nshow" \
      | _fzf_single)

    if [ "$subcmd" = "branch" ]; then
      local name
      name=$(bash -c 'read -r -p "Branch name: "; echo $REPLY')
      git stash branch "$name" "$inst"
    elif [ "$subcmd" = "show" ]; then
      git stash show "$inst" --patch-with-stat
    else
      for f in $(echo "$inst"); do
        git stash "$subcmd" "$f"
      done
    fi
  fi
}

gitf-ignoreio() {
  local inst
  inst=$(
    git ignore-io -l \
      | perl -lpe 's/\s+/\n/g' \
      | _fzf_multi
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      git ignore-io --append "$f"
    done
  fi
}

gitf() {
  local cmd header

  header=$(_fzf_header)
  cmd=("submodule" "commit" "ignoreio" "stash")

  _fzf_command
}
