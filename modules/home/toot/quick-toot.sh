#Requires: toot rofi
set -euo pipefail

if [ -v ALREADY_TOOTING ]; then
    echo -en "\0prompt\x1fToot (\n"
    if [ -v 1 ]; then
        echo "$@" | toot post
    fi
else
    if ! toot auth | rg ACTIVE >/dev/null; then
        rofi-sensible-terminal -e toot login
    fi

    export ALREADY_TOOTING="totally"
    rofi -show toot -modi "toot:$0"
fi
