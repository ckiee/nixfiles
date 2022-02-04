# nixfiles

A collection of ~~slightly-above-average~~ overkill `.nix` files managing a bunch of computers all over Earth.

## How can I run this on my machine?

You probably shouldn't be; this is open source to serve as just a reference, but I'll be impressed if you figure it out.

## Hosts

### bokkusu

Our main server, rented from [OVH](https://ovh.com).
(_Currently full, no more services for this one_)

| Property | bokkusu                                   |
| :------- | :---------------------------------------- |
| CPU      | 2x Intel Core Processor (Haswell, no TSX) |
| Memory   | 7.6Gi                                     |
| Disk     | 80G                                       |

### cookiemonster

The main desktop machine and the beefiest of them all.

| Property | cookiemonster                     |
| :------- | :-------------------------------- |
| CPU      | AMD Ryzen 5 3600 6-Core Processor |
| Memory   | 15Gi                              |
| Disk     | 538G SATA, 465G NVME              |

### drapion

A _Raspberry Pi_, serving as the DNS server and occasional jumphost.

| Property | drapion          |
| :------- | :--------------- |
| CPU      | Broadcom BCM2835 |
| Memory   | 895Mi            |
| Disk     | 30G              |

### thonkcookie

A _Lenovo Thinkpad T480s_, serving as our desktop machine when someone dares to make us move more than a meter.

It's mostly just for browsing and also occasionally, remote development with [cookiemonster](#cookiemonster).

| Property | thonkcookie                              |
| :------- | :--------------------------------------- |
| CPU      | Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz |
| Memory   | 7.5Gi                                    |
| Disk     | 238.5G                                   |

### pansear

An old PC running random services and a Windows VM.

| Property | pansear                                 |
| :------- | :-------------------------------------- |
| CPU      | Intel(R) Core(TM) i5-3470 CPU @ 3.20GHz |
| Memory   | 7.6Gi                                   |
| Disk     | 111.8G                                  |

### pookieix

Another Pi, too boring to boot up to get specs. It's used for the 3D printer.

### virt

A QEMU VM for testing that's been used a total of... one time!

### aquamarine

A laptop motherboard in a dollar-store box. Very unreliable, slow, and only has a somewhat-functioning WiFi card for
networking.

## License

Read the `LICENSE` file, silly!
