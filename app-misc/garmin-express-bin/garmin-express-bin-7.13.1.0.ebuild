# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev xdg

# Pinned to 7.13.1.0 (July 2022), fetched from the Internet Archive.
# Newer Express versions (tested: 7.29.1.0) identify USB-mass-storage devices
# through the Windows USB stack (STORAGE_DEVICE_NUMBER -> parent disk ->
# USB\VID_091E), which Wine does not provide, so they never find a device.
# 7.13 still finds devices by scanning drives for Garmin/GarminDevice.xml,
# which works with Wine's mount manager (tested with an Edge 530, 2026-10-06).
# When Express offers its self-update to a newer version, decline it.
ARCHIVE_TS="20220718202324"
DOTNET48="ndp48-x86-x64-allos-enu.exe"
DOTNET40="dotNetFx40_Full_x86_x64.exe"
FXC2="https://raw.githubusercontent.com/mozilla/fxc2/master/dll"

DESCRIPTION="Garmin Express: update and sync Garmin devices (Windows build via Wine)"
HOMEPAGE="https://www.garmin.com/express"
SRC_URI="
	https://web.archive.org/web/${ARCHIVE_TS}id_/https://download.garmin.com/omt/express/GarminExpress.exe
		-> ${P}.exe
	https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/${DOTNET48}
	https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/${DOTNET40}
	${FXC2}/d3dcompiler_47.dll -> ${PN}-d3dcompiler_47.dll
	${FXC2}/d3dcompiler_47_32.dll -> ${PN}-d3dcompiler_47_32.dll
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-emulation/winetricks
	virtual/wine
	x11-libs/libnotify
"
BDEPEND="media-gfx/icoutils"

QA_PREBUILT="*"

src_unpack() {
	:
}

src_prepare() {
	default

	wrestool -x -t 14 "${DISTDIR}/${P}.exe" -o "${T}/garmin-express.ico" \
		|| die "extracting icon failed"
	icotool -x -o "${T}" "${T}/garmin-express.ico" || die "converting icon failed"
}

src_install() {
	local dir=/opt/garmin-express

	insinto ${dir}
	newins "${DISTDIR}/${P}.exe" GarminExpress.exe
	echo "${PV}" > "${T}/version" || die
	doins "${T}/version"
	insinto ${dir}/redist
	doins "${DISTDIR}/${DOTNET48}" "${DISTDIR}/${DOTNET40}"
	newins "${DISTDIR}/${PN}-d3dcompiler_47.dll" d3dcompiler_47.dll
	newins "${DISTDIR}/${PN}-d3dcompiler_47_32.dll" d3dcompiler_47_32.dll

	newbin "${FILESDIR}"/garmin-express garmin-express

	# let the logged-in user access Garmin USB devices (vendor 091e)
	udev_newrules "${FILESDIR}"/garmin-express.rules 70-garmin-express.rules

	local png size
	for png in "${T}"/garmin-express_*x32.png; do
		[[ -e ${png} ]] || continue
		size=$(basename "${png}" | sed -E 's/.*_([0-9]+)x[0-9]+x32\.png/\1/')
		newicon -s ${size} "${png}" garmin-express.png
	done

	make_desktop_entry garmin-express "Garmin Express" garmin-express "Utility;" \
		"StartupWMClass=express.exe"
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload

	elog "Start Garmin Express with 'garmin-express' or from the application menu."
	elog "The first start prepares a per-user Wine prefix in"
	elog "  \${XDG_DATA_HOME:-~/.local/share}/garmin-express/prefix"
	elog "(.NET 4.8 + Garmin Express itself; takes 10-20 minutes, once)."
	elog "Override with GARMIN_EXPRESS_WINEPREFIX; remove that directory to reset."
	elog
	elog "Plug in the device so the desktop mounts it (it becomes a Wine drive),"
	elog "then use 'Add a Device'. Decline the offer to update Garmin Express:"
	elog "newer versions cannot see devices under Wine. MTP-only watches are not"
	elog "visible to Wine at all; use the Garmin Connect phone app for those."
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
