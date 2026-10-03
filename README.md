# gentoo-overlay (`::local`)

Gert Pellin's persoonlijke Gentoo-overlay: ebuilds voor software die niet (of
niet in de gewenste versie) in `::gentoo` zit, gebruikt en getest op een
amd64-systeem met KDE Plasma.

Deze overlay is **self-contained**: hangt een pakket af van iets dat alleen in
een andere overlay (bv. `::guru`) bestaat, dan staat een kopie van die ebuild
hier, zodat de overlay niet afhangt van het syncen van andere overlays.

## Pakketten

| Pakket | Versie(s) | Omschrijving | Licentie | Opmerking |
|---|---|---|---|---|
| `dev-libs/libpresage` | 0.9.1 | Predictieve tekstinvoer (woordvoorspelling) | GPL-3 | |
| `dev-python/PyMuPDF` | 1.27.2.3 | Python-bibliotheek voor PDF-bewerking | AGPL-3 | afhankelijkheid van rayforge |
| `dev-python/asyncudp` | 0.11.0 | High-level asyncio UDP-sockets | MIT | afhankelijkheid van rayforge |
| `dev-python/ezdxf` | 1.4.4 | DXF-tekeningen maken en bewerken | MIT | kopie uit `::guru`, afhankelijkheid van rayforge |
| `dev-python/mupdf` | 1.27.2 | Python-bindings voor MuPDF | AGPL-3 | afhankelijkheid van PyMuPDF; gepind op `app-text/mupdf` uit `::gentoo` |
| `dev-python/pipcl` | 2 | Build-helper voor MuPDF/PyMuPDF | AGPL-3 | afhankelijkheid van PyMuPDF |
| `dev-python/py-slvs` | 1.0.6 | Python-binding voor de SolveSpace constraint solver | GPL-3 | |
| `dev-python/pymupdf-fonts` | 1.0.4 | Optionele fonts voor PyMuPDF | OFL-1.1 | afhankelijkheid van PyMuPDF |
| `dev-python/pyvips` | 3.2.0 | Python-binding voor libvips | MIT | afhankelijkheid van rayforge |
| `dev-python/raygeo` | 1.49.0 | 2D/3D-geometrie voor CAD/CAM (Rust + Python) | MIT | afhankelijkheid van rayforge |
| `dev-python/svgelements` | 1.9.6-r1 | SVG-parser | MIT | kopie uit `::guru`, afhankelijkheid van rayforge |
| `dev-python/vtracer` | 0.6.15 | Raster-naar-vector (VTracer, Rust + Python) | MIT | afhankelijkheid van rayforge |
| `media-gfx/bambu-suite-bin` | 01.05.00.00 | Bambu Suite (laser- en snijmodule H2D/H2C) — Windows-build via Wine | all-rights-reserved | zie hieronder |
| `media-gfx/rayforge` | 1.11.0 | G-code-generator en besturing voor lasersnijders/-graveerders | MIT | |
| `media-plugins/gst-plugins-rs` | 1.29.1 | GStreamer-plugins in Rust | LGPL-2.1+/MIT/Apache-2.0/MPL-2.0 | work in progress, nog geen Manifest |
| `media-sound/noson-app` | 5.6.17 | SONOS-bediening voor Linux | GPL-3 | ook in `::guru` |
| `media-video/stremio` | 1.0.0_beta12 | Stremio (nieuwe Rust/CEF-shell) | GPL-3 | |

Alle ebuilds gebruiken EAPI 8 en staan op `~amd64`.

### `media-gfx/bambu-suite-bin`

Bambu Lab levert Bambu Suite alleen voor Windows en macOS. De ebuild pakt de
Windows-installer (Inno Setup) met `innoextract` uit naar `/opt/bambu-suite`;
de launcher `bambu-suite` maakt per gebruiker een Wine-prefix aan in
`~/.local/share/bambu-suite/prefix` (Windows 11-modus, VC++-runtime uit de
installer, bijgeleverde fonts). Getest met `app-emulation/wine-vanilla-11.0`.

- Prefix resetten: verwijder `~/.local/share/bambu-suite/prefix`.
- Andere prefix: `BAMBU_SUITE_WINEPREFIX=/pad bambu-suite`.
- De licentie moet expliciet geaccepteerd worden:
  `echo 'media-gfx/bambu-suite-bin all-rights-reserved' >> /etc/portage/package.license`

**Nieuwe versie:** de download-URL bevat een tijdstempel dat niet uit het
versienummer volgt. Het bump-script zoekt de nieuwste link op en maakt de
ebuild + Manifest aan:

```sh
bash /var/db/repos/local/media-gfx/bambu-suite-bin/files/bambu-suite-bump
```

## Installatie

De repository is privé, dus syncen gaat via SSH met een sleutel die toegang
heeft tot GitHub.

```ini
# /etc/portage/repos.conf/local.conf
[local]
location = /var/db/repos/local
masters = gentoo
sync-type = git
sync-uri = git@github.com:switch87/gentoo-overlay.git
auto-sync = no
priority = 9999
```

```sh
git clone git@github.com:switch87/gentoo-overlay.git /var/db/repos/local
```

Zet daarna de gewenste pakketten op `~amd64`, bv.:

```sh
echo 'media-gfx/rayforge ~amd64' >> /etc/portage/package.accept_keywords/local
emerge -av media-gfx/rayforge
```

## Werkwijze

- Nieuwe ebuilds eerst in een staging-overlay testen (`ebuild … manifest`,
  `ebuild … clean install`, `pkgcheck scan`, `emerge -p`), daarna hierheen.
- Na elke wijziging aan een ebuild of `files/`: `ebuild <pkg>.ebuild manifest`.
- `metadata/md5-cache/` wordt niet in git bijgehouden.
- Committen en pushen naar `main`.

## Bijdragers

- **Gert Pellin** (`switch87`) — onderhouder — pellingert@gmail.com

## Licentie

De ebuilds, patches en scripts in deze repository vallen onder de
[GNU General Public License v2](LICENSE), net als de Gentoo-tree. De software
die ze installeren valt onder de eigen licentie van elk pakket (zie de
`LICENSE`-variabele in de ebuild en de tabel hierboven).
