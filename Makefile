HOST=$(shell hostname)
NIXFILES_PATH=$(shell pwd)

.PHONY: deploy debug virt

clean: result *.qcow2
	rm result *.qcow2
deploy:
	mo deploy morph.nix switch --passwd
debug:
	mo deploy morph.nix switch --passwd --on=$(HOST)*

pushsecrets: secrets/*
	rsync --delete --recursive secrets/* bokkusu:$(NIXFILES_PATH)

emails:
	nix eval --impure --expr 'let pkgs = (import (import ./nix/sources.nix).nixpkgs) { }; util = (pkgs.callPackage ./modules/services/mailserver/util.nix {}); in (builtins.trace ("e-mails: \n" + (builtins.concatStringsSep "\n" (util.process (pkgs.lib.fileContents ./secrets/email-salt) util.default-aliases))) "")' 1>/dev/null

installer:
	nixos-generate -c hosts/installer/default.nix -f install-iso
