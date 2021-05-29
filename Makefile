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
