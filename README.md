# nixfiles

> *These are .Nix files*
>
> *The blue things on these silicon chips*
>
> *Well, they're not edible*
>
> *But don't you think they oughta be?*
>
> *They're just golden russet groupings*
>
> *So they're not that good for eating.*
> [〜](https://www.youtube.com/watch?v=nwXIpjQjEy8)

A collection of relatively overkill `.nix` files managing my fleet of computers on this planet.

![Dual monitor screenshot of `cookiemonster`.
On screen are Doom Emacs, Element, and Cantata](screenshot.png)

You can see all the 120-ish [`./modules`](https://github.com/ckiee/nixfiles/tree/master/modules)
by exploring that directory.

I'm particularly proud of
[`aldhy`](https://github.com/ckiee/nixfiles/tree/master/modules/services/aldhy/): 
a CI/CD service to build the fleet's NixOS system derivations.
It's written in bash and running at
[aldhy.tailnet.ckie.dev](https://aldhy.tailnet.ckie.dev).

## Abstraction
NixOS lets you forget
[what hosts are running what](https://github.com/ckiee/nixfiles/blob/0560c489fca45d40aebb2ed9251b34dd6d233b4d/bin/c#L64)
and once you deploy a new service
it usually just keeps on working,
even if you [suddenly decide to migrate it](https://github.com/ckiee/nixfiles/commit/387b08e).

Nix [has a lot of problems](https://xeiaso.net/talks/nixos-pain-2021-11-10)
but if you have [a lot of time](https://github.com/hlissner/dotfiles#frequently-asked-questions)
[and you're open to trying out new ways of doing things](https://illustris.tech/devops/why-you-should-NOT-never-ever-use-nixos/),
it becomes extremely enjoyable after a while.

> *But even still..!*
>
> *Me want eat!*
>
> *Me want tasty computer treat!*
>
> *Me want spoonful.*
>
> *Me want sweet Nix from the beach!*

## License

Read the `LICENSE` file, silly! 😛
