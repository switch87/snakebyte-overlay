# snakebyte

`snakebyte` is Gert Pellin's personal Gentoo overlay: ebuilds for software
that is not in `::gentoo` (or not in the wanted version), used and tested on
an amd64 system running KDE Plasma.

The overlay is **self-contained**: when a package depends on something that
only exists in another overlay (e.g. `::guru`), a copy of that ebuild lives
here, so this overlay never depends on other overlays being synced.

## Applications

### Bambu Suite — `media-gfx/bambu-suite-bin`

Bambu Lab's software for the laser and cutting modules of the H2D/H2C. Bambu
Lab only ships it for Windows and macOS, so this package runs the Windows
build under Wine:

- the Inno Setup installer is unpacked with `innoextract` into
  `/opt/bambu-suite` at emerge time;
- the `bambu-suite` launcher creates a per-user Wine prefix in
  `~/.local/share/bambu-suite/prefix` on first start (Windows 11 mode,
  VC++ runtime and fonts from the installer);
- reset the prefix by removing that directory; use another one with
  `BAMBU_SUITE_WINEPREFIX=/path bambu-suite`.

Tested with `app-emulation/wine-vanilla-11.0`. The download URL contains an
upload timestamp, so new versions are created with the bump script:

```sh
bash /var/db/repos/snakebyte/media-gfx/bambu-suite-bin/files/bambu-suite-bump
```

### Garmin Express — `app-misc/garmin-express-bin`

Garmin's desktop tool to update the firmware and maps of Garmin devices and
sync activities. Garmin only ships it for Windows and macOS, so this package
runs the Windows build under Wine:

- the installer, the .NET Framework 4.0 and 4.8 installers and `d3dcompiler_47` are
  installed into `/opt/garmin-express` at emerge time (no downloads later);
- the `garmin-express` launcher creates a per-user Wine prefix in
  `~/.local/share/garmin-express/prefix` on first start (winetricks
  `dotnet48` + `d3dcompiler_47` fed from `/opt`, the GDI renderer (the
  embedded Chromium window stays black otherwise), then a silent install of
  Garmin Express; 10-20 minutes, once). A newer package version is installed
  into the existing prefix on the next start;
- a udev rule gives the logged-in user access to Garmin USB devices (vendor
  `091e`);
- reset the prefix by removing that directory; use another one with
  `GARMIN_EXPRESS_WINEPREFIX=/path garmin-express`.

**Version 7.13.1.0 on purpose (tested 2026-10-06 with an Edge 530):** newer
Garmin Express versions (e.g. 7.29.1.0) identify USB-mass-storage devices
through the Windows USB stack (storage device number → parent disk →
`USB\VID_091E`), which Wine does not provide, so they never find a device.
7.13.1.0 (July 2022, fetched from the Internet Archive) still scans the
drives for `Garmin/GarminDevice.xml`: plug the device in, let the desktop
mount it (Wine turns it into a drive letter) and use *Add a Device*.
Decline Express's offer to update itself. MTP-only watches stay invisible to
Wine; use the Garmin Connect phone app for those.

### map-update — `sci-geosciences/map-update`

Keeps offline maps in Garmin `.img` format up to date in QMapShack and/or on
every connected Garmin device in USB drive mode. Which maps, where from and
under which file name is configured in `~/.config/map-update.toml` (created
with an example on the first run); a map is only downloaded when the server
reports a new version. Free sources with stable URLs:
[OpenFietsMap](https://ligfietser.dev.openstreetmap.org/openfietsmap/),
[Freizeitkarte](https://download.freizeitkarte-osm.de/garmin/latest/) and
[alternativaslibres.org](https://alternativaslibres.org/en/downloads.php)
(worldwide).

```sh
map-update --check                          # what is new?
map-update                                  # download and install
systemctl --user enable --now map-update.timer   # weekly, Sunday 20:00
```

All options: `map-update --help`; full documentation and map sources in
[`sci-geosciences/map-update/files/README.md`](sci-geosciences/map-update/files/README.md)
(installed as `/usr/share/doc/map-update-*/README.md`).

### LightBurn — `media-gfx/lightburn-bin` and `media-gfx/lightburn-wine`

Layout and control software for laser cutters. LightBurn dropped Linux after
1.7.08, so there are two packages that can be installed side by side:

- **`lightburn-bin`** (1.7.08) — the last native Linux release, installed into
  `/opt/lightburn` with its bundled Qt 5 (Qt 5 is no longer in `::gentoo`).
  Pulls in `dev-libs/openssl-compat:1.1.1`, which the bundled Qt needs for
  TLS (license activation, update checks). Command: `lightburn`.
- **`lightburn-wine`** (2.x) — the current Windows release under Wine, with a
  per-user prefix in `~/.local/share/lightburn-wine/prefix` (Windows 10 mode,
  VC++ runtimes from the installer). On first start the settings of the native
  version (`~/.config/LightBurn/prefs.ini`) are copied into the prefix.
  Command: `lightburn-wine`.

LightBurn 2.x enumerates cameras through WinRT APIs that Wine does not
implement and crashes at start-up because of it. `lightburn-wine` builds a
small stub DLL (`files/winrt-capture-stub.c`) that implements
`MediaFrameSourceGroup` and `DeviceInformation` as "no cameras present" and
registers it in the prefix. As a result, **camera support is not available**
in the Wine version. LightBurn 2.x also needs a license whose update period
covers the installed version. LightBurn Software does not support running
LightBurn under Wine.

New Windows releases are picked up from LightBurn's `Release.json`:

```sh
bash /var/db/repos/snakebyte/media-gfx/lightburn-wine/files/lightburn-wine-bump
```

### Rayforge — `media-gfx/rayforge`

G-code generator and control software for laser cutters and engravers. Most of
the `dev-python/*` packages in this overlay are its dependencies, including
the Rust-based `raygeo`, `raydriver` and `vtracer`.

`dev-python/mupdf` builds against the system MuPDF and requires exactly the
same version (`~app-text/mupdf-${PV}`). Always update `app-text/mupdf`,
`dev-python/mupdf` and `dev-python/PyMuPDF` together, and pin `app-text/mupdf`
to that version in `package.accept_keywords` (e.g.
`=app-text/mupdf-1.28.2* ~amd64`).

### Stremio — `media-video/stremio`

The new GTK 4 / WebKitGTK based Stremio shell, built from source. Upstream
asks for GTK 4.22 and libadwaita 1.9, but uses nothing newer than GTK 4.20 and
libadwaita 1.8; the ebuild lowers those API levels so it builds against stable
GTK. Needs `net-libs/webkit-gtk:6` and `media-video/mpv[libmpv]`.

### Snapmaker Luban — `media-gfx/snapmaker-luban-bin`

The 3-in-1 software (3D printing, laser, CNC) for Snapmaker machines. Luban
is open source (AGPL-3), but building the Electron app from source would need
hundreds of npm packages fetched at build time, so this package installs the
official Linux build into `/opt/snapmaker-luban`. It bundles Electron 15
(Chromium 94, 2021), which no longer receives security updates. Command:
`snapmaker-luban`.

### Claude Desktop — `app-misc/claude-desktop-bin`

Anthropic's official Claude Desktop for Linux (Chat, Cowork and Code),
installed from the `.deb` in Anthropic's apt repository. The `cowork` USE
flag (on by default) pulls in QEMU, OVMF and virtiofsd for the Cowork virtual
machine. Cowork only looks for UEFI firmware at Debian's paths, so with
`USE=cowork` the package links `/usr/share/OVMF/OVMF_{CODE,VARS}.fd` to the
firmware from `sys-firmware/edk2-bin`. New versions are created with the bump
script, which reads the apt index:

```sh
bash /var/db/repos/snakebyte/app-misc/claude-desktop-bin/files/claude-desktop-bump
```

### Claude Code — `dev-util/claude-code`

The `::gentoo` ebuild, bumped here to the current release on Claude Code's
*stable* channel. Its `managed-settings.json` turns off the self-updater and
the installation checks, so Claude Code never installs copies into the home
directory. Drop this copy again once `::gentoo` catches up.

```sh
bash /var/db/repos/snakebyte/dev-util/claude-code/files/claude-code-bump
```

### Wispr Flow — `app-accessibility/wispr-flow-bin`

Voice dictation for office work. Wispr Flow has no official Linux build; this
package uses the unofficial
[wispr-flow-linux](https://github.com/wispr-flow-linux/wispr-flow-linux) port
(the proprietary app repackaged with a Linux Electron runtime). The port's
Linux helper (text injection, push-to-talk) is **built from source** here,
with a fix for [#123](https://github.com/wispr-flow-linux/wispr-flow-linux/issues/123):
the prebuilt helper re-presses modifiers that are physically held during a
paste on its own virtual keyboard and never releases them, so Ctrl/Alt stay
logically pressed on Wayland. A udev rule gives the active session access to
`/dev/uinput` and `/dev/input`. Run `wispr-flow --doctor` to check the setup.

### wkhtmltopdf for Odoo — `media-gfx/wkhtmltopdf-odoo-bin`

**For Odoo users.** Odoo renders PDF reports with wkhtmltopdf and needs the
0.12.6.1 build "with patched Qt" (headers, footers, page numbering); the
wkhtmltopdf project itself is archived and this release is effectively kept
alive for Odoo. The package installs the upstream Debian bookworm build into
`/usr`; it links only against libraries from `::gentoo`.

### noson — `media-sound/noson-app`

Controls SONOS speakers from Linux (Qt 6).

### Tailscale on your own LAN — `net-vpn/tailscale-lan-route`

**Fix for Tailscale `--accept-routes` on Linux.** When a node (often the home
router) advertises your LAN as a subnet route, Linux sends traffic to your
*own* LAN through that subnet router, NATed, even while you are at home.
Devices on the LAN then can't connect back. A typical symptom is **KDE Connect
transfers from the PC to the phone stuck at 0%**; another is `ip route get
<LAN-IP>` showing `dev tailscale0 table 52`. The package adds a policy rule
(`lookup main suppress_prefixlength 0`, priority 5200) so that directly
connected networks win. Away from home Tailscale's routes still apply. It
also keeps systemd-networkd from deleting the rule. After installing, run
`systemctl enable --now tailscale-lan-route.service`.

Full explanation, diagnosis, configuration and a non-Gentoo version:
[docs/tailscale-lan-route.md](docs/tailscale-lan-route.md).

### KDE Connect with location sharing and remote connect — `kde-misc/kdeconnect`

The `::gentoo` ebuild of KDE Connect with an extra **geolocation plugin**
(the desktop side of
[kdeconnect-android MR !529](https://invent.kde.org/network/kdeconnect-android/-/merge_requests/529)).
The phone sends its GPS position; the plugin

- offers it as NMEA 0183 sentences on a TCP port on **localhost only**
  (default 10110), for programs like QMapShack or gpsd;
- exposes the position on D-Bus;
- asks the phone for its location **only while someone listens** (an NMEA
  client or a D-Bus caller) and tells it to stop afterwards.

The NMEA output is off by default. These patches are not part of KDE Connect;
this copy (revision `-r101`, so it wins over `::gentoo`) is dropped again if
KDE Connect itself gains these features. When `::gentoo` bumps KDE Connect, the
patches are rebased and a new `-r101` is added here.

The phone needs a KDE Connect build that includes MR !529 (the release on
Google Play/F-Droid does not yet), and the plugin must be enabled for the
device. To use the phone as a GPS in QMapShack:

1. KDE Connect settings → the phone → *Location* plugin → configure →
   enable **Offer this device's location to applications** (port 10110).
2. QMapShack → *Realtime* → add source *GPS Tether* → host `localhost`,
   port `10110`, *auto. conn.*

**Remote connect** (KDE Connect over a VPN such as Tailscale, pending upstream
review): in the KDE Connect app's settings, *Devices by Address* takes IPv4
addresses **or host names** (e.g. the phone's MagicDNS name). KDE Connect
sends its discovery packet to them on start and on network changes, right away
when a connection drops, and then again while a paired device is unreachable
(after one minute, backing off to every 15 minutes), so the phone reconnects
over the VPN by itself after it left the home Wi-Fi. A connection that stops
acknowledging data is dropped after 60 s instead of hanging for many minutes.
Also included: the upstream TCP keepalive tuning from master (not in 26.04).

### Adobe Creative Cloud apps — `app-emulation/adobewine` and `app-emulation/wine-adobe`

Photoshop, Illustrator, Premiere Pro, Audition and Media Encoder under Wine,
packaged from [AdobeWine](https://github.com/le-birnes/AdobeWine):

- **`wine-adobe`** (11.18) — Wine with the AdobeWine patch set, installed next
  to other Wine versions in `/usr/lib/wine-adobe-11.18`.
- **`adobewine`** (0.1.0) — the `adobewine` command. It creates a per-user
  prefix in `~/.local/share/adobewine/prefix` (DXVK, vkd3d-proton behind
  AdobeWine's D3D12 shim, fonts, registry settings), starts the apps and adds
  them to the menu. DXVK, vkd3d-proton, wine-gecko and wine-mono come from
  Portage; nothing is downloaded at run time except what winetricks fetches.

```sh
adobewine setup [--windows-fonts <Fonts folder of your own Windows>]
adobewine run <Creative Cloud installer>.exe   # sign in, install the apps
adobewine launchers                            # menu entries
adobewine photoshop
```

On top of AdobeWine 0.1.0 these fixes are applied; each is also offered
upstream (pull requests 3–5) and dropped here once merged:

- **Segoe UI from Selawik** (`media-fonts/selawik`) when no Windows fonts are
  given. Without a real "Segoe UI" family Photoshop's menu bar stays white and
  the UI hangs at full CPU; a font substitute does not help DirectWrite.
- **Direct3D 12 feature level 12_0 or 12_1** is reported on GPUs whose Vulkan
  driver offers only 11_x (e.g. Intel UHD 620 with Mesa), 12_1 when the GPU
  has the rest of it, as on Windows. Otherwise Photoshop finds no GPU and no
  VRAM, and Camera Raw refuses to edit ("requires GPU acceleration"; it wants
  12_1 on Intel).
- `adobewine photoshop` and the menu entries use the **newest installed
  release** (e.g. Photoshop 2025), and menu entries get the app's icon.

After upgrading, run `adobewine setup` once more so an existing prefix gets the
fixes. Photoshop needs a lot of memory while it starts: on a machine with 8 GB
RAM add disk swap (a swapfile in its own btrfs subvolume), or it is killed by
the OOM killer. A Creative Cloud subscription is required; Adobe does not
support running its apps under Wine.

### Touch screen edge rejection — `kde-plasma/kwin` and `kde-plasma/plasma-desktop`

Some touch screens (here a Wacom HID 5412 in a ThinkPad L13 2-in-1) report
ghost touches along the edges: a greasy bezel, a thumb holding the lid, or the
charger's noise. The screen only reports positions (no pressure or contact
size), so its sensitivity cannot be tuned, but edge ghosts can be recognised:
they start very close to an edge and do not move.

These packages are the `::gentoo` 6.7.5 ebuilds with one patch each:

- **KWin**: a touch that starts closer than a per-device width to an edge of
  the touch screen is held back; it is delivered (with its original start) as
  soon as it moves more than 3 mm, so edge swipes keep working, and dropped if
  it ends before that. Width 0–10 mm, off by default; D-Bus property
  `touchEdgeRejectionWidth` on `org.kde.KWin.InputDevice`, stored in
  `kcminputrc`.
- **plasma-desktop**: the setting in System Settings → Touchscreen ("Ignore
  touches starting near the edge", with the width in pixels).

Install both together (plasma-desktop needs the patched KWin at build time),
then log out and in again. Not part of KDE; dropped again if KWin gains this
itself. Back to `::gentoo`:
`emerge --oneshot =kde-plasma/kwin-6.7.5-r1 =kde-plasma/plasma-desktop-6.7.5`.

## Installation

With `app-eselect/eselect-repository`:

```sh
eselect repository add snakebyte git https://github.com/switch87/snakebyte-overlay.git
emaint sync -r snakebyte
```

Or by hand:

```ini
# /etc/portage/repos.conf/snakebyte.conf
[snakebyte]
location = /var/db/repos/snakebyte
sync-type = git
sync-uri = https://github.com/switch87/snakebyte-overlay.git
auto-sync = yes
```

All packages are keyworded `~amd64`; accept them per package, e.g.:

```sh
echo 'media-gfx/rayforge ~amd64' >> /etc/portage/package.accept_keywords/snakebyte
emerge -av media-gfx/rayforge
```

The closed-source packages (`bambu-suite-bin`, `claude-desktop-bin`,
`lightburn-bin`, `lightburn-wine`, `wispr-flow-bin`) also need their license
accepted:

```sh
echo 'media-gfx/lightburn-bin all-rights-reserved' >> /etc/portage/package.license
```

To use a laser over USB-serial, your user must be able to open the serial
device, e.g. `usermod -aG dialout <user>`.

## Packages

| Package | Version | Description | License | Notes |
|---|---|---|---|---|
| `app-emulation/adobewine` | 0.1.0-r3 | AdobeWine: prefix setup and launcher for Adobe Creative Cloud apps | LGPL-2.1+, ZLIB, MIT | upstream scripts + fixes offered upstream (PR 3–5); DXVK 3.1.1, vkd3d-proton 3.0.1 |
| `app-emulation/wine-adobe` | 11.18 | Wine with the AdobeWine patch set | LGPL-2.1+ | slotted; adobewine needs it with USE `gecko mono vulkan wow64` |
| `app-misc/claude-desktop-bin` | 2.9939.4-r1 | Claude Desktop (official Linux build) | all-rights-reserved | USE=cowork pulls in QEMU |
| `app-misc/garmin-express-bin` | 7.13.1.0 | Garmin Express (device updates and sync), Windows build via Wine | all-rights-reserved | pinned to 7.13 (newer versions can't see devices under Wine); Edge 530 tested with wine-vanilla-11.0 |
| `app-accessibility/wispr-flow-bin` | 1.6.957 | Wispr Flow voice dictation (unofficial Linux port) | all-rights-reserved, Unlicense | helper built from source with a stuck-modifier fix |
| `dev-util/claude-code` | 2.1.285 | Claude Code CLI | all-rights-reserved | bump of the `::gentoo` ebuild (stable channel) |
| `dev-lang/bun-bin` | 1.3.14 | Bun JavaScript runtime | MIT | copy from `::guru`; used by Claude Code channel plugins |
| `dev-libs/libpresage` | 0.9.1 | Intelligent predictive text entry | GPL-3 | |
| `dev-python/PyMuPDF` | 1.28.2 | Python library for PDF manipulation | AGPL-3 | rayforge dependency |
| `dev-python/anthropic` | 0.116.0 | Claude API client library | MIT | copy from `::guru` |
| `dev-python/asyncudp` | 0.11.0 | High-level asyncio UDP sockets | MIT | rayforge dependency |
| `dev-python/ezdxf` | 1.4.4 | Create and modify DXF drawings | MIT | copy from `::guru`; rayforge dependency |
| `dev-python/http-snapshot` | 0.1.9 | HTTP snapshot testing | MIT | copy from `::guru`; anthropic test dependency |
| `dev-python/httpx-aiohttp` | 0.2.0 | aiohttp transport for httpx | BSD | copy from `::guru`; anthropic test dependency |
| `dev-python/jiter` | 0.16.0 | Fast iterable JSON parser (Rust) | MIT | copy from `::guru`; anthropic dependency |
| `dev-python/mupdf` | 1.28.2 | Python bindings for MuPDF | AGPL-3 | PyMuPDF dependency; needs the same `app-text/mupdf` version |
| `dev-python/pipcl` | 13 | Build helper for MuPDF/PyMuPDF | AGPL-3 | PyMuPDF dependency |
| `dev-python/playwright` | 1.63.0 | Browser automation (bundled node driver) | Apache-2.0 | browsers live in `~/.cache/ms-playwright` |
| `dev-python/py-slvs` | 1.0.6 | Python binding for the SolveSpace constraint solver | GPL-3 | |
| `dev-python/pymupdf-fonts` | 1.0.5 | Optional fonts for PyMuPDF | OFL-1.1 | PyMuPDF dependency |
| `dev-python/pyee` | 13.0.1 | Port of node's EventEmitter | MIT | playwright dependency (needs <14) |
| `dev-python/pytest-base-url` | 2.1.0 | pytest plugin for base URLs | MPL-2.0 | pytest-playwright dependency |
| `dev-python/pytest-playwright` | 0.9.0 | pytest plugin for Playwright | Apache-2.0 | |
| `dev-python/pyvips` | 3.2.0 | Python binding for libvips | MIT | rayforge dependency |
| `dev-python/raydriver` | 0.2.0 | Machine drivers for rayforge (Rust + Python) | MIT | rayforge dependency |
| `dev-python/raygeo` | 1.59.0 | 2D/3D geometry for CAD/CAM (Rust + Python) | MIT | rayforge dependency |
| `dev-python/ruida-pa` | 0.21.2 | Ruida protocol analyzer and driver | MIT | rayforge dependency; bokeh/textual optional |
| `dev-python/standardwebhooks` | 1.0.1 | Standard Webhooks reference library | MIT | copy from `::guru`; anthropic test dependency |
| `dev-python/svgelements` | 1.9.6-r1 | SVG parser | MIT | copy from `::guru`; rayforge dependency |
| `dev-python/vtracer` | 0.6.15 | Raster to vector tracing (Rust + Python) | MIT | rayforge dependency |
| `kde-misc/kdeconnect` | 26.04.3-r101 | KDE Connect with the geolocation plugin (phone location as NMEA on localhost and on D-Bus) and remote connect (custom devices by host name, retry with backoff, dead-link timeout, settings UI) | GPL-2+ | `::gentoo` ebuild + patches; geolocation needs kdeconnect-android MR !529 on the phone; dropped once upstream merges |
| `media-fonts/selawik` | 1.01 | Microsoft's open, metric-compatible fallback for Segoe UI | OFL-1.1 | used by adobewine when no Windows fonts are given |
| `media-gfx/bambu-suite-bin` | 01.05.00.00 | Bambu Suite (H2D/H2C laser and cutter), Windows build via Wine | all-rights-reserved | |
| `media-gfx/lightburn-bin` | 1.7.08 | LightBurn, last native Linux release | all-rights-reserved | |
| `media-gfx/lightburn-wine` | 2.1.04 | LightBurn, Windows build via Wine | all-rights-reserved, GPL-2 (stub DLL) | no camera support |
| `media-gfx/photocraft-bin` | 0.3.0 | PhotoCraft layered image editor with PSD support (Rust, Vulkan) | MIT or Apache-2.0, OFL-1.1 | upstream Linux tarball; early alpha |
| `media-gfx/snapmaker-luban-bin` | 4.15.2 | Snapmaker Luban (3D printing, laser, CNC) | AGPL-3+ (bundled Electron: MIT, BSD) | bundles Electron 15 |
| `media-gfx/wkhtmltopdf-odoo-bin` | 0.12.6.1_p3 | wkhtmltopdf with patched Qt, for Odoo PDF reports | LGPL-3+ | |
| `media-gfx/rayforge` | 1.12.0 | G-code generator and laser control | MIT | |
| `media-sound/noson-app` | 5.7.5 | SONOS controller (Qt 6) | GPL-3 | older version in `::guru` |
| `media-video/stremio` | 1.2.1 | Stremio (GTK 4 / WebKitGTK shell) | GPL-3 | patched to build against stable GTK |
| `sci-geosciences/map-update` | 1.2 | Keep offline maps (Garmin .img) up to date in QMapShack and on Garmin devices | GPL-2 | Python script + systemd user timer |
| `kde-plasma/kwin` | 6.7.5-r101 | KWin with touch screen edge rejection | GPL-2+ | `::gentoo` ebuild + patch; install with plasma-desktop |
| `kde-plasma/plasma-desktop` | 6.7.5-r101 | Plasma desktop with the edge rejection setting in the Touchscreen KCM | GPL-2+ | `::gentoo` ebuild + patch; needs kwin-6.7.5-r101 |
| `net-vpn/tailscale-lan-route` | 1.0 | Prefer directly connected networks over Tailscale subnet routes | GPL-2 | fixes LAN traffic going through a subnet router; [docs](docs/tailscale-lan-route.md) |

All ebuilds use EAPI 8. `eclass/stainless-python.eclass` is a copy from
`::guru`, needed by `dev-python/anthropic`.

## Workflow

- Test new ebuilds in a staging overlay first (`ebuild … manifest`,
  `ebuild … clean install`, `pkgcheck scan`, `emerge -p`), then copy them here.
- After every change to an ebuild or its `files/`: `ebuild <pkg>.ebuild manifest`.
- `metadata/md5-cache/` is not tracked in git.
- Commit and push to `main`.

## Contributors

- **Gert Pellin** (`switch87`) — maintainer — gert@pellin.be

## License

The ebuilds, patches and scripts in this repository are licensed under the
[GNU General Public License v2](LICENSE), like the Gentoo tree. The software
they install is covered by its own license (see the `LICENSE` variable in each
ebuild and the table above).
