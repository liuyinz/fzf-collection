#!/usr/bin/env bash

_gitf_sha() {
  local commit

  commit=$(
    git log --pretty=oneline --abbrev-commit \
      | _fzf_read \
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
  top_level=$(git rev-parse --show-toplevel)
  module_file="$top_level/.gitmodules"

  module=$(
    grep -oP '(?<=\[submodule ").*?(?="\])' $module_file \
      | sort -f \
      | _fzf_read --multi
  )

  if [ -n "$module" ]; then
    # shellcheck disable=SC2028
    subcmd=$(
      echo "update-remote\ndelete\nhomepage\ndir\ninit\ndeinit\nupdate-init\npin\nunpin" \
        | _fzf_read
    )

    for i in $(echo "$module"); do
      f="$top_level/$(git config --file "$module_file" submodule."$i".path)"
      case $subcmd in
        update-remote)
          if [[ "$(git config --file $module_file submodule."$i".pin)" == "true" ]]; then
            echo "$i is pinned."
          else
            echo "$i ..."
            git submodule update --remote "$f"
          fi
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
        pin)
          git config --file "$module_file" submodule."$i".pin true
          ;;
        unpin)
          git config --file "$module_file" submodule."$i".pin false
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
      | _fzf_read \
      | perl -F':' -lne 'print $F[1]' \
      | tac
  )

  if [ -n "$inst" ]; then
    local subcmd

    # shellcheck disable=SC2028
    subcmd=$(echo "pop\nbranch\ndrop\napply\nshow" \
      | _fzf_read)

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
      | _fzf_read --multi
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      git ignore-io --append "$f"
    done
  fi
}

gitf() {
  local header opt

  header=$(_fzf_header)
  opt=("submodule" "commit" "ignoreio" "stash")

  _fzf_command
}
