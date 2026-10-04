# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Layout, editing and control software for laser cutters (last Linux release)"
HOMEPAGE="https://lightburnsoftware.com/"
SRC_URI="https://release.lightburnsoftware.com/LightBurn/Release/LightBurn-v${PV}/LightBurn-Linux64-v${PV}.7z"
S="${WORKDIR}/LightBurn"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

# Qt 5.15 and most of its dependencies are bundled (Qt5 is gone from
# ::gentoo). The bundled Qt was built against OpenSSL 1.1 and dlopen()s
# it at runtime for TLS (license activation, update checks).
RDEPEND="
	app-arch/bzip2
	app-arch/zstd
	dev-libs/expat
	dev-libs/gmp
	dev-libs/libgpg-error
	dev-libs/libusb:1
	dev-libs/openssl-compat:1.1.1
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd[X]
	sys-fs/e2fsprogs
	virtual/zlib
	x11-libs/libX11
	x11-libs/libxcb
"
BDEPEND="app-arch/7zip"

QA_PREBUILT="*"

src_install() {
	local dir=/opt/lightburn

	# AppRun is just a symlink to the binary
	rm AppRun || die

	insinto ${dir}
	doins -r lib plugins translations languages qt.conf
	exeinto ${dir}
	doexe LightBurn

	# keep the bundled libraries' executable bits
	find "${ED}${dir}"/{lib,plugins} -name '*.so*' -type f -exec chmod 0755 {} + || die

	# The binary has RUNPATH=$ORIGIN/lib and finds qt.conf next to itself.
	# No Wayland platform plugin is bundled, so force XWayland.
	newbin - lightburn <<-EOF
		#!/bin/sh
		export QT_QPA_PLATFORM=xcb
		exec "${EPREFIX}${dir}/LightBurn" "\$@"
	EOF

	newicon -s 512 LightBurn.png lightburn.png
	make_desktop_entry lightburn LightBurn lightburn "Graphics;Engineering;" \
		"StartupWMClass=LightBurn"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LightBurn ${PV} is the last version released for Linux; newer"
	elog "versions are available as media-gfx/lightburn-wine."
	elog
	elog "To use a laser over USB-serial your user must be able to open"
	elog "the serial device, e.g.: usermod -aG dialout <user>"
}
