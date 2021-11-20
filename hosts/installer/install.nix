{ config, pkgs, lib, ... }:

let
  installer = with pkgs;
    let
      system = (import <nixpkgs/nixos/lib/eval-config.nix> {
        system = "x86_64-linux";
        modules = [ ../thonkcookie ];
      }).config.system.build.toplevel;
    in writeShellScriptBin "installer" ''
      set -eu
      INSTALL_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
      [ -d /sys/firmware/efi/efivars/ ] || (echo "Aborting, not running in EFI!" && exit 1)

      # let's just do it in the background async
      nix-store --verify-path ${system} &

      sudo sfdisk --wipe always $1 <<-END
      label: gpt
      boot : start=2048, size=204800, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name=boot-$INSTALL_ID
      zfs  : start=206848, type=516E7CBA-6ECF-11D6-8FF8-00022D09712B, name=zfs-$INSTALL_ID
      END

      for part in zfs boot; do
        echo Waiting for label $part-$INSTALL_ID
        while true; do [ -L /dev/disk/by-partlabel/$part-$INSTALL_ID ] && break; done
      done

      sudo mkfs.vfat /dev/disk/by-partlabel/boot-$INSTALL_ID


      for idx in $(seq 3); do
        sudo zpool create \
          -o ashift=12 \
          -O mountpoint=none \
          -O atime=off \
          -O acltype=posixacl \
          -O xattr=sa \
          -O compression=lz4 \
          -O keyformat=passphrase \
          -O encryption=on \
          -O refreservation=1G \
          zroot /dev/disk/by-partlabel/zfs-$INSTALL_ID || true
      done

      sudo zfs create -p -o mountpoint=legacy zroot/local/nix
      sudo zfs create -p -o mountpoint=legacy zroot/local/root
      sudo zfs create -p -o mountpoint=legacy zroot/safe/persist

      sudo zfs snapshot zroot/local/root@blank

      sudo mount -t zfs zroot/local/root /mnt
      sudo mkdir /mnt/{persist,nix,boot}
      sudo mount /dev/disk/by-partlabel/boot-$INSTALL_ID /mnt/boot
      sudo mount -t zfs zroot/local/nix /mnt/nix
      sudo mount -t zfs zroot/safe/persist /mnt/persist

      #nixos-generate-config --show-hardware-config --root /mnt >/mnt/persist/hardware.nix

      fg || true
      sudo ${config.system.build.nixos-install}/bin/nixos-install \
        --system ${system} \
        --no-root-passwd \
        --cores 0

      echo 'You can reboot now (:'
    '';

in {
  services.getty.helpLine = "\nYou can run `installer $DISK` to wipe $DISK, initialize ZFS and install NixOS.";
  environment.systemPackages = [ installer ];
}
