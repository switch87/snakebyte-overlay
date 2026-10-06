# map-update

Keep offline maps in Garmin `.img` format up to date in
[QMapShack](https://github.com/Maproom/qmapshack) and on Garmin devices.

Each map is a download from an HTTP(S) server: a `.zip` with a `.img` inside,
or a plain `.img`. `map-update` asks the server whether there is a new version
(ETag/Last-Modified) and only then downloads it and installs it into the
QMapShack map directory, onto every connected Garmin device, or both.

## Usage

```sh
map-update --check                        # which maps have a new version?
map-update                                # download and install them
map-update --map "OpenFietsMap Benelux"   # only this map (repeatable)
map-update --force                        # reinstall everything
map-update --no-garmin                    # leave Garmin devices alone
map-update --config PATH                  # another configuration file
map-update --help                         # all options, configuration summary
```

Weekly automatic updates (Sunday 20:00, catches up after the computer was off):

```sh
systemctl --user enable --now map-update.timer
journalctl --user -u map-update           # what the last runs did
```

After an update, reload the maps in QMapShack: right-click the map list →
*Reload maps*. QMapShack does not look into subdirectories of a map directory.

## Configuration

`~/.config/map-update.toml`, created with an example on the first run.

```toml
[general]
qmapshack_maps = "~/QMapShackData/Maps"   # "" = skip QMapShack
garmin_labels = ["GARMIN"]                # drive labels of Garmin devices
keep_downloads = false                    # keep downloaded .zip files in ~/.cache/map-update

[[map]]
name = "OpenFietsMap Benelux"
url = "https://ligfietser.dev.openstreetmap.org/openfietsmap/benelux/full/OpenFietsMap.zip"
file_in_zip = "*gmapsupp.img"             # glob; must match exactly one file
qmapshack_name = "OpenFietsMap_Benelux.img"   # "" = not in QMapShack
garmin_name = "gmapsupp-openfietsmap.img"     # "" = not on Garmin devices
```

Add one `[[map]]` block per map. Give every map its own `garmin_name`
(starting with `gmapsupp` is customary): Garmin devices load every `.img` in
their `Garmin/` directory, and maps can be switched on and off on the device
(on an Edge: *activity profile → Navigation → Map → Map Information*).

## Map sources

Free sources with stable download URLs (the URL must not change between
releases). Map data © OpenStreetMap contributors; check each source's licence.

| Source | Contents | URL pattern | `file_in_zip` |
|---|---|---|---|
| [OpenFietsMap](https://ligfietser.dev.openstreetmap.org/openfietsmap/) | cycling map, Benelux (`full` with contours, `light` without) | `…/openfietsmap/benelux/full/OpenFietsMap.zip` | `*gmapsupp.img` |
| [Freizeitkarte](https://download.freizeitkarte-osm.de/garmin/latest/) | topographic map with contours, European countries and regions | `…/garmin/latest/DEU_en_gmapsupp.img.zip` | `*gmapsupp.img` |
| [alternativaslibres.org](https://alternativaslibres.org/en/downloads.php) | routable maps worldwide, per country (`_DEM` = with elevation data) | `https://alternativaslibres.org/files/gmapsupp_Philippines_DEM.zip` | `*.img` |

Some OpenFietsMap regions (Alps, Germany, …) have the release date in the file
name; those cannot be followed automatically.

Mind the size: a large country with contour lines is 3–4 GB unpacked. Devices
without an SD slot (e.g. Edge 530: 16 GB) cannot hold many of them.

## How it works

- **New version**: the server's ETag (or Last-Modified/size) differs from the
  one recorded at the last installation.
- **Downloads** go to `~/.cache/map-update`, are resumed after an
  interruption, checked for size, and zip files are tested before use. They
  are removed after installation unless `keep_downloads = true`.
- **Garmin devices** are drives with one of the `garmin_labels` that contain
  `Garmin/GarminDevice.xml`; unmounted ones are mounted with `udisksctl`.
  Each device (model + serial number) is tracked separately, so a device
  connected later gets the map then, copied from the QMapShack directory when
  that already has the current version (no new download).
- **Safe copies**: maps are written as `.part`, synced, and only then renamed,
  so pulling the cable never leaves a half-written map. Other files on the
  device are never touched. There must be 50 MB to spare, otherwise the device
  is skipped with a message.
- **State** (installed versions per map and device):
  `~/.local/state/map-update.json`.

## Requirements

Python ≥ 3.11 (standard library only), `lsblk` (util-linux), `udisksctl`
(udisks) for mounting devices, optionally `notify-send` for a desktop
notification.
