{ config, pkgs, lib, ... }:

with lib;

let
  installer = with pkgs;
    let
      system = (import "${pkgs.path}/nixos/lib/eval-config.nix" {
        system = "x86_64-linux";
        modules = [
          ./base.nix
          ({ config, ... }: { config.fileSystems."/".device = "fake"; })
        ];
      }).config.system.build.toplevel;
      gitRepo = ../../.git;
    in writeShellScriptBin "installer" ''
      set -eu
      if [ $USER != root ]; then
        echo 'you must be root!' 1>&2
        exit 1
      fi
      INSTALL_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
      [ -d /sys/firmware/efi/efivars/ ] || (echo "Aborting, not running in EFI!" && exit 1)

      # let's just do it in the background async
      # this is the only reference to $}system{ so it will make stuff much slower
      nix-store --verify-path ${system} &

      sfdisk --wipe always $1 <<-END
      label: gpt
      boot : start=2048, size=204800, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name=boot-$INSTALL_ID
      zfs  : start=206848, type=516E7CBA-6ECF-11D6-8FF8-00022D09712B, name=zfs-$INSTALL_ID
      END

      for part in zfs boot; do
        echo Waiting for label $part-$INSTALL_ID
        while true; do [ -L /dev/disk/by-partlabel/$part-$INSTALL_ID ] && break; done
      done

      mkfs.vfat /dev/disk/by-partlabel/boot-$INSTALL_ID

      for idx in $(seq 3); do
        zpool create \
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

      zfs create -p -o mountpoint=legacy zroot/local/nix
      zfs create -p -o mountpoint=legacy zroot/local/root
      zfs create -p -o mountpoint=legacy zroot/safe/persist

      zfs snapshot zroot/local/root@blank

      mount -t zfs zroot/local/root /mnt
      mkdir /mnt/{persist,nix,boot}
      mount /dev/disk/by-partlabel/boot-$INSTALL_ID /mnt/boot
      mount -t zfs zroot/local/nix /mnt/nix
      mount -t zfs zroot/safe/persist /mnt/persist


      mkdir -p /mnt/persist
      git clone ${gitRepo} /mnt/persist/nixfiles
      cd /mnt/persist/nixfiles

      mkdir secrets
      cp ${../../secrets/email-salt} secrets/email-salt
      cp ${../../secrets/unix-password.nix} secrets/unix-password.nix

      echo -n 'Pick a hostname, alphanumeric, 61 chars max: '
      read NEW_HOST
      mkdir "hosts/"$NEW_HOST
      cp ${./base.nix} "hosts/"$NEW_HOST/default.nix
      sed -ie 's/#_#//' "hosts/"$NEW_HOST/default.nix
      sed -ie "s/CHANGE_HOST/$NEW_HOST/" "hosts/"$NEW_HOST/default.nix
      nixos-generate-config --show-hardware-config --root /mnt >"hosts/"$NEW_HOST/hardware.nix

      fg || true
      new_sys=$(nix-build -I nixos-config=./hosts/$NEW_HOST -E '((import (((import ((import ./nix/sources.nix).nixpkgs)) {}).path + "/nixos")) {}).system' --no-out-link)
      ${config.system.build.nixos-install}/bin/nixos-install \
        --system $new_sys \
        --no-root-passwd \
        --cores 0 \
        --no-channel-copy

      cd /
      umount -R /mnt
      zpool export zroot

      echo 'You can reboot now (:'
    '';

in {
  services.getty.helpLine = ''

    You can run `sudo installer $DISK` to wipe $DISK, initialize ZFS and install NixOS.'';
  environment.systemPackages = [ installer ];
}
