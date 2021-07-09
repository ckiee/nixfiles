.PHONY: deploy debug virt

clean: result *.qcow2
	rm result *.qcow2
deploy:
	morph deploy morph.nix switch --passwd
debug:
	morph deploy morph.nix switch --passwd --show-trace --on=$(COOKIE_HOSTNAME)*
virt:
	NIXOS_CONFIG=$(COOKIE_NIXFILES_PATH)/hosts/virt/default.nix nixos-rebuild build-vm
	QEMU_NET_OPTS='hostfwd=tcp::5555-:22' $(COOKIE_NIXFILES_PATH)/result/bin/run-virt-vm &
	while true; do ssh localhost -o ConnectTimeout=1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 5555; sleep 0.2; done

pushsecrets: secrets/*
	rsync --delete --recursive secrets/* bokkusu:~/git/nixfiles/secrets/

emails:
	nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; util = (pkgs.callPackage ./modules/services/mailserver/util.nix {}); in (builtins.trace ("e-mails: \n" + (builtins.concatStringsSep "\n" (util.process (pkgs.lib.fileContents ./secrets/email-salt) util.default-aliases))) "")' 1>/dev/null
