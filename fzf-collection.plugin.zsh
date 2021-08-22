# set options if not defined
if [[ -z "$FZF_COLLECTION_OPTS" ]]; then
  export FZF_COLLECTION_OPTS="--reverse --cycle --multi --sort --exact --info=inline"
fi

fzf_opts=($(echo ${FZF_COLLECTION_OPTS}))

for f in "${0:h:A}"/fzf-*.sh; do
  source $f
done
