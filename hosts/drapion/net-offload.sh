#Requires: coreutils android-tools ripgrep usbutils iproute2 iptables openssh
set -e
defroute=""
upstream_defroute=""
phone_iface=""
adb wait-for-device
while true; do
    if ! lsusb | rg 'network tethering' >/dev/null; then
        # disable wifi, enable data
        adb shell 'svc wifi disable; svc data enable'
        # enable tethering
        adb shell 'am start -n com.android.settings/.TetherSettings; for code in 20 20 20 20 66; do input keyevent $code; done'
        sleep 2
        break
    fi
done
while true; do
    for p in /sys/class/net/*/device/driver/module; do
        if readlink $p | rg rndis_host >/dev/null && ip r | rg "default via 192\.168\.0\."; then
            phone_iface="$(echo "$p" | rg -o '/sys/class/net/(.+)/device' -r '$1')"
            defroute=$(ip route | rg "default via" | rg -v "$phone_iface")
            ip r del $defroute
            break 2
        fi
    done
done
# things deferred for exit
finish() {
    ip r add $defroute
    router ip r del $upstream_new
    router ip r add $(echo "$upstream_routes" | rg "default via.+vlan")
    nmcli c up ifname $MAIN_IFACE || true
}
trap finish EXIT
# setup iptables
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X
iptables -t nat -A POSTROUTING -o $phone_iface -j MASQUERADE
# force ourselves upstream too
router() {
    echo "router$" $@
    ssh $SSH_OPTS root@darcher.atori -- $@
}
upstream_routes="$(router ip r)"
our_ip="$(ip a show dev $MAIN_IFACE | rg "inet (.+)/" -or '$1')"
upstream_new="default via $our_ip dev br0"
router ip r del $(echo "$upstream_routes" | rg "default via.+vlan")
router ip r add $upstream_new
# now we don't let it out of sight!
while true; do
    adb get-state >/dev/null
    sleep 1
    # fight other networking tools... just in case
    ip r del $defroute >/dev/null 2>&1 || true
done
