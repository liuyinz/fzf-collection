# set options if not defined
if [[ -z "$FZF_COLLECTION_OPTS" ]]; then
  FZF_COLLECTION_OPTS="
  --reverse
  --cycle
  --multi
  --sort
  --exact
  --info=inline"
fi

fzf_opts=($(echo "${FZF_COLLECTION_OPTS}"))

if [[ -z "$FZF_COLLECTION_MODULES" ]]; then
  FZF_COLLECTION_MODULES=(
    fzf-default
    fzf-browser
    fzf-brew
    fzf-git
    fzf-pip)
fi

for f in "${FZF_COLLECTION_MODULES[@]}"; do
  source "${0:h:A}/$f.sh"
done
