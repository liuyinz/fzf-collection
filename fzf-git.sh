#! /usr/bin/env bash

# GIT
# ------------------
# gsha - get git commit sha
gsha() {
  local commit

  commit=$(git log --pretty=oneline --abbrev-commit \
    | fzf "${fzf_opts[@]}" --header='[commits: ]' \
    | sed "s/ .*//")

  echo "$commit"
}

# gck - checkout git commit
gck() {
  local commit
  commit=$(gsha)

  if [[ $commit ]]; then
    git checkout "$commit"
  fi
}

# gwf - checkout git branch/tag
gwf() {
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

# [G]it r[E]store [F]zf
gef() {
  local inst
  inst=$(git ls-files -m --exclude-standard \
    | fzf "${fzf_opts[@]}" --header='[git restore:]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      git restore "$f"
    done
  fi
}

# [G]it r[E]store [S]taged
# SEE https://www.javaer101.com/en/article/16751334.html
ges() {
  local inst
  inst=$(git diff --name-only --cached \
    | xargs -I '{}' realpath --relative-to=. "$(git rev-parse --show-toplevel)"/'{}' \
    | fzf "${fzf_opts[@]}" --header='[git restore: --staged]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      git restore --staged "$f"
    done
  fi
}

# [G]it r[E]store [A]ll
gea() {
  local inst
  inst=$(git diff --name-only HEAD \
    | xargs -I '{}' realpath --relative-to=. "$(git rev-parse --show-toplevel)"/'{}' \
    | fzf "${fzf_opts[@]}" --header='[git restore: --staged --worktree]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      git restore --staged --worktree "$f"
    done
  fi
}

# [G]it [S]ub[M]odule [I]nteractive
gsmi() {
  local module
  local subcmd

  # SEE https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository#comment84215697_12641787
  module=$(
    git config -z --file \
      "$(git rev-parse --show-toplevel)/.gitmodules" --get-regexp '\.path$' \
      | sed -nz 's/^[^\n]*\n//p' \
      | tr '\0' '\n' \
      | fzf "${fzf_opts[@]}" --header='[git submodule: ]'
  )

  if [[ $module ]]; then
    # shellcheck disable=SC2028
    subcmd=$(echo "update-remote\ndelete\nbrowse\nhome\ninit\ndeinit\nupdate-init" \
      | fzf "${fzf_opts[@]}" --header='[git submodule: subcmd]')

    for i in $(echo "$module"); do
      f="$(git rev-parse --show-toplevel)"/$i
      case $subcmd in
        update-remote)
          echo "$i ..."
          git submodule update --remote "$f"
          ;;
        delete)
          git delete-submodule --force "$f"
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

# [G]it [ST]ash [I]nteractive
gsti() {
  local inst
  inst=$(git stash list \
    | fzf "${fzf_opts[@]}" --header='[git stash: pop]' \
    | awk 'BEGIN { FS = ":" } { print $1 }' \
    | tac)

  if [[ $inst ]]; then
    local subcmd

    # shellcheck disable=SC2028
    subcmd=$(echo "pop\nbranch\ndrop\napply\nshow" \
      | fzf "${fzf_opts[@]}" --header='[git stash: subcmd]')

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

# [G]it [I]gnore-io [F]zf
gif() {
  local inst
  inst=$(git ignore-io -l \
    | sed -e "s/[[:space:]]\+/\n/g" \
    | fzf "${fzf_opts[@]}" --header='[git ignore-io:append]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      git ignore-io --append "$f"
    done
  fi
}
