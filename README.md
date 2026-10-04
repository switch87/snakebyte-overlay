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
| `app-misc/claude-desktop-bin` | 2.9939.4-r1 | Claude Desktop (official Linux build) | all-rights-reserved | USE=cowork pulls in QEMU |
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
| `media-gfx/bambu-suite-bin` | 01.05.00.00 | Bambu Suite (H2D/H2C laser and cutter), Windows build via Wine | all-rights-reserved | |
| `media-gfx/lightburn-bin` | 1.7.08 | LightBurn, last native Linux release | all-rights-reserved | |
| `media-gfx/lightburn-wine` | 2.1.04 | LightBurn, Windows build via Wine | all-rights-reserved, GPL-2 (stub DLL) | no camera support |
| `media-gfx/snapmaker-luban-bin` | 4.15.2 | Snapmaker Luban (3D printing, laser, CNC) | AGPL-3+ (bundled Electron: MIT, BSD) | bundles Electron 15 |
| `media-gfx/wkhtmltopdf-odoo-bin` | 0.12.6.1_p3 | wkhtmltopdf with patched Qt, for Odoo PDF reports | LGPL-3+ | |
| `media-gfx/rayforge` | 1.12.0 | G-code generator and laser control | MIT | |
| `media-sound/noson-app` | 5.7.5 | SONOS controller (Qt 6) | GPL-3 | older version in `::guru` |
| `media-video/stremio` | 1.2.1 | Stremio (GTK 4 / WebKitGTK shell) | GPL-3 | patched to build against stable GTK |
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

- **Gert Pellin** (`switch87`) — maintainer — pellingert@gmail.com

## License

The ebuilds, patches and scripts in this repository are licensed under the
[GNU General Public License v2](LICENSE), like the Gentoo tree. The software
they install is covered by its own license (see the `LICENSE` variable in each
ebuild and the table above).
