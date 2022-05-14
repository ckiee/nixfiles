#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl htmlq ripgrep jq

cd "$(dirname "$0")"
curl https://social.pixie.town/about/more | htmlq -t 'tr td:first-child' | rg '^([a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+)$' --replace '"$1"' | jq -s . > bad_instances.json
