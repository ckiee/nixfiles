{ config, pkgs, lib, ... }:

let
  installer = with pkgs;
    let
      system = (import <nixpkgs/nixos/lib/eval-config.nix> {
        system = "x86_64-linux";
        modules = [ ../thonkcookie ];
      }).config.system.build.toplevel;
    in writeShellScriptBin "installer" ''
      [ $USER != root ] && sudo $(realpath "$${""}{0}") "$${""}{@}"; exit $?
      INSTALL_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 8 | head -n 1)

      [ -d /sys/firmware/efi/efivars/ ] || (echo "Aborting, not running in EFI!" && exit 1)

      # let's just do it in the background async
      nix-store --verify-path ${system} &

      sudo sfdisk --wipe always /dev/vda <<-END
      label: gpt
      boot : start=2048, size=204800, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name=boot-$INSTALL_ID
      zfs  : start=206848, type=516E7CBA-6ECF-11D6-8FF8-00022D09712B, name=zfs-$INSTALL-ID
      END

      mkfs.vfat /dev/disk/by-partlabel/boot-$INSTALL_ID

      zpool create
        -o ashift=12 \
        -O mountpoint=none \
        -O atime=off \
        -O acltype=posixacl \
        -O xattr=sa \
        -O compression=lz4 \
        -O keyformat=passphrase \
        -O encryption=on \
        -O refreservation=1G \
        zroot /dev/disk/by-partlabel/zfs-$INSTALL_ID

      zfs create -p -o mountpoint=legacy zroot/local/nix
      zfs create -p -o mountpoint=legacy zroot/local/root
      zfs create -p -o mountpoint=legacy zroot/safe/persist

      zfs snapshot rpool/local/root@blank

      mkdir /mnt
      mount -t zfs zroot/local/root /mnt
      mkdir /mnt/{persist,nix}
      mount -t zfs zroot/local/nix /mnt/nix
      mount -t zfs zroot/safe/persist /mnt/persist

      nixos-generate-config --show-hardware-config --root /mnt >/mnt/persist/hardware.nix

      fg
      ${config.system.build.nixos-install}/bin/nixos-install \
        --system ${system} \
        --no-root-passwd \
        --cores 0

      echo 'You can reboot now (:'
    '';

in {
  services.getty.helpLine = "\nYou can run `installer $DISK` to wipe $DISK, initialize ZFS and install NixOS.";
  environment.systemPackages = [ installer ];
}
