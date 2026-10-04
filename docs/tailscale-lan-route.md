# Tailscale subnet routes break traffic on your own LAN (Linux)

`net-vpn/tailscale-lan-route` fixes a long-standing Tailscale behaviour on
Linux: with `--accept-routes`, traffic to your **own** LAN goes through a
Tailscale subnet router instead of straight over Ethernet/Wi-Fi, as soon as
some node advertises that LAN as a subnet route. This page explains how to
recognise the problem, why it happens, and how the package solves it. The
rule it installs works on any distribution; see
[Without Gentoo](#without-gentoo).

Upstream: [tailscale/tailscale#1227](https://github.com/tailscale/tailscale/issues/1227)
(locked) and the feature request
[tailscale/tailscale#7947](https://github.com/tailscale/tailscale/issues/7947).

## Symptoms

You run Tailscale on a Linux machine with `--accept-routes`, and some node,
often your home router (OpenWrt, Turris, a NAS, a Raspberry Pi), advertises
your home network as a subnet route (e.g. `192.168.1.0/24`). Then, even while
you are at home on that very network:

- **KDE Connect: sending a file from the PC to the phone stays at 0%** and
  times out. Browsing the phone from Dolphin and receiving files from the phone
  still work.
- LAN devices can't reach services on the PC, or connections hang in
  `SYN-RECV` (`ss -tan`).
- Devices on the LAN see connections from the PC as coming from the subnet
  router's address, not from the PC.
- Anything that needs the other side to connect back fails: file transfers,
  DLNA/UPnP, game streaming, printers or scanners that push data, SMB oddities,
  slow transfers through the router.

## Diagnosis

Ask the kernel which way it sends traffic to a device on your LAN:

```console
$ ip route get 192.168.1.159
192.168.1.159 dev tailscale0 table 52 src 100.71.97.50
```

`dev tailscale0 table 52` means you have this problem. It should say
`dev wlan0` / `dev eth0` with your LAN address as `src`. `tailscale status
--json` shows which peer advertises the route (`PrimaryRoutes`).

## Cause

Tailscale puts accepted subnet routes in routing table 52 and adds policy rules
that consult it **before** the main table:

```console
$ ip rule
0:      from all lookup local
5210:   from all fwmark 0x80000/0xff0000 lookup main
5230:   from all fwmark 0x80000/0xff0000 lookup default
5250:   from all fwmark 0x80000/0xff0000 unreachable
5270:   from all lookup 52
32766:  from all lookup main
32767:  from all lookup default
```

So `192.168.1.0/24 dev tailscale0` in table 52 wins over the directly
connected `192.168.1.0/24 dev wlan0` in the main table. Your traffic goes
through the tunnel to the subnet router, which NATs it onto the LAN. That
breaks things in two ways:

1. LAN devices see the router as the source and connect back to the router,
   where nothing listens. KDE Connect asks the phone to fetch the file from
   the PC, so the phone connects to the router and the transfer never starts.
2. Even when a device connects to the PC's real LAN address, the PC's replies
   (SYN-ACK) to that device are routed into `tailscale0` as well, so the
   connection never completes.

Neither can be fixed inside an application: Linux picks the route for every
packet by its destination.

## Fix

The package adds one policy rule just before Tailscale's rules:

```console
$ ip rule
...
5200:   from all lookup main suppress_prefixlength 0
5210:   from all fwmark 0x80000/0xff0000 lookup main
...
5270:   from all lookup 52
```

`lookup main suppress_prefixlength 0` consults the main table but ignores a
match on the default route (`/0`). So:

- **On your LAN**, main has `192.168.1.0/24 dev wlan0`. That route wins, and
  traffic to LAN devices goes out directly.
- **Away from home**, main has no such route, only the default route, which
  is suppressed. The lookup falls through to table 52, and Tailscale still
  routes `192.168.1.0/24` through your subnet router. Remote access keeps
  working.
- **Tailscale peers** (`100.64.0.0/10`, `fd7a:115c:a1e0::/48`) and the
  internet are unaffected.

This is the same technique `wg-quick` uses for WireGuard full tunnels. The
rule is added for IPv4 and IPv6.

The commonly posted workaround, `ip rule add to 192.168.1.0/24 lookup main
priority 2500`, also fixes it at home. Away from home, though, it sends LAN
traffic to your default gateway, so you lose access to your home network
through Tailscale.

### systemd-networkd

systemd-networkd deletes routing policy rules it didn't create
(`ManageForeignRoutingPolicyRules=yes` by default), even when it manages no
links at all, for example whenever it restarts. The package therefore installs
`/usr/lib/systemd/networkd.conf.d/50-tailscale-lan-route.conf` with
`ManageForeignRoutingPolicyRules=no`. Tailscale re-adds its own rules when
it reconfigures; this rule would otherwise be gone until the next boot.

## Installation (Gentoo)

```sh
eselect repository add snakebyte git https://github.com/switch87/snakebyte-overlay.git
emaint sync -r snakebyte
echo 'net-vpn/tailscale-lan-route ~amd64' >> /etc/portage/package.accept_keywords/tailscale-lan-route
emerge --ask net-vpn/tailscale-lan-route
systemctl enable --now tailscale-lan-route.service
```

Check it:

```console
$ /usr/libexec/tailscale-lan-route status
5200:   from all lookup main suppress_prefixlength 0
5200:   from all lookup main suppress_prefixlength 0
$ ip route get 192.168.1.159
192.168.1.159 dev wlan0 src 192.168.1.248
```

Applications that already had a connection over the old path need to
reconnect. For KDE Connect, restart `kdeconnectd` or toggle the phone's Wi-Fi.

## Configuration

`/etc/conf.d/tailscale-lan-route`:

| Variable | Default | Meaning |
|---|---|---|
| `LAN_PREFIXES` | empty | Space-separated IPv4/IPv6 prefixes. Empty: every route in the main table that is more specific than the default route wins over Tailscale (recommended). Set e.g. `"192.168.1.0/24"` to limit the rule to specific networks. |
| `PRIORITY` | `5200` | Rule priority; must be below Tailscale's rules (5210 and up). |

Restart the service after a change:
`systemctl restart tailscale-lan-route.service`.

Restricting to `LAN_PREFIXES` matters if the main table holds routes you want
Tailscale to override, e.g. a route from another VPN.

## Without Gentoo

The fix is one command, which lasts until reboot:

```sh
sudo ip -4 rule add lookup main suppress_prefixlength 0 priority 5200
sudo ip -6 rule add lookup main suppress_prefixlength 0 priority 5200
```

To make it persistent, copy
[`files/tailscale-lan-route`](../net-vpn/tailscale-lan-route/files/tailscale-lan-route)
to `/usr/libexec/` and
[`files/tailscale-lan-route.service`](../net-vpn/tailscale-lan-route/files/tailscale-lan-route.service)
to `/etc/systemd/system/`, then run `systemctl enable --now
tailscale-lan-route`. If systemd-networkd is running, also add the
[networkd drop-in](../net-vpn/tailscale-lan-route/files/50-tailscale-lan-route.conf)
to `/etc/systemd/networkd.conf.d/`.

## Uninstall

```sh
systemctl disable --now tailscale-lan-route.service
emerge --ask --depclean net-vpn/tailscale-lan-route
```

Stopping the service removes the rule.
