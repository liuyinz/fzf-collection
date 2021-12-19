#! /usr/bin/env bash

_gitf_sha() {
  local commit

  commit=$(
    git log --pretty=oneline --abbrev-commit \
      | _fzf_single_header \
      | sed "s/ .*//"
  )

  echo "$commit"
}

gitf-commit() {
  local commit
  commit=$(_gitf_sha)

  if [ -n "$commit" ]; then
    git checkout "$commit"
  fi
}

gitf-branch() {
  local tags
  local branches
  local target

  tags="$(
    git tag \
      | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
  )" || return

  branches="$(
    git branch --all \
      | grep -v HEAD \
      | sed 's/.* //' \
      | sed 's#remotes/[^/]*/##' \
      | sort -u \
      | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'
  )" || return

  target="$(
    printf '%s\n%s' "$tags" "$branches" \
      | fzf \
        --no-hscroll \
        --ansi \
        +m \
        -d '\t' \
        -n 2 \
        -q "$*"
  )" || return

  git checkout "$(echo "$target" | awk '{print $2}')"
}

gitf-submodule() {
  local module
  local subcmd

  # SEE https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository#comment84215697_12641787
  module=$(
    git config -z --file \
      "$(git rev-parse --show-toplevel)/.gitmodules" --get-regexp '\.path$' \
      | sed -nz 's/^[^\n]*\n//p' \
      | tr '\0' '\n' \
      | _fzf_multi_header
  )

  if [ -n "$module" ]; then
    # shellcheck disable=SC2028
    subcmd=$(echo "update-remote\ndelete\nbrowse\nhome\ninit\ndeinit\nupdate-init" \
      | _fzf_single --header "$(_headerf "Git Submodule: Option")")

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
        browse)
          # SEE https://stackoverflow.com/a/786515/13194984
          (cd "$f" && exec gh browse)
          ;;
        home)
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
  local inst
  inst=$(
    git stash list \
      | _fzf_single_header \
      | awk 'BEGIN { FS = ":" } { print $1 }' \
      | tac
  )

  if [ -n "$inst" ]; then
    local subcmd

    # shellcheck disable=SC2028
    subcmd=$(echo "pop\nbranch\ndrop\napply\nshow" \
      | _fzf_single --header "$(_headerf "Git Stash: Option")")

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
      | sed -e "s/[[:space:]]\+/\n/g" \
      | _fzf_multi_header
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      git ignore-io --append "$f"
    done
  fi
}

gitf() {
  local cmd select
  cmd=("submodule" "branch" "commit" "ignoreio" "stash")
  select=$(
    echo "${cmd[@]}" \
      | tr ' ' '\n' \
      | _fzf_single --header "$(_headerf "Git Fzf")"
  )
  if [ -n "$select" ]; then
    case $select in
      submodule) gitf-submodule ;;
      branch) gitf-branch ;;
      commit) gitf-commit ;;
      ignoreio) gitf-ignoreio ;;
      stash) gitf-stash ;;
    esac
  fi
}
