#Requires: rofi avahi ripgrep
set -euo pipefail

if [ -v IN_ROFI ]; then
    echo -en "\0prompt\x1fNetwork intent (\n"
    if [ -v 1 ]; then
        echo "-" "$@" >> ~/Sync/org/netintent.org
        our_ip="$(avahi-resolve -4n "$(hostname)".local | rg ".+\s(.+\b)" --replace '$1')"
        ssh root@darcher.atori 'iptables -L |grep -E "DROP.+\s\s'$our_ip'">/dev/null && iptables -D FORWARD -s '$our_ip' -j DROP -o vlan2 || iptables -I FORWARD -s '$our_ip' -j DROP -o vlan2'
    fi
else
    export IN_ROFI="totally"
    rofi -show totally -modi "totally:$0"
fi
