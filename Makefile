deploy:
	morph deploy morph.nix switch --passwd

debug:
	morph deploy morph.nix switch --passwd --show-trace --on=$(COOKIE_HOSTNAME)*

