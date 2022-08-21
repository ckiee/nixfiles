#Requires: fmouse xorg.xwininfo ripgrep coreutils

# HACKity HACK
if ! [ "$(xwininfo -tree -root | rg -i rsibreak | wc -l)" -gt 5 ]; then
    exec fmouse
fi
