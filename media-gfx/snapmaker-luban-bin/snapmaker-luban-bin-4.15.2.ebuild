# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN="Snapmaker-luban"
MY_P="${MY_PN}-${PV}-linux-x64"

DESCRIPTION="3-in-1 software for Snapmaker machines (3D printing, laser, CNC)"
HOMEPAGE="
	https://www.snapmaker.com/snapmaker-luban
	https://github.com/Snapmaker/Luban
"
SRC_URI="https://github.com/Snapmaker/Luban/releases/download/${PV}/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

# Luban itself is AGPL-3; the bundled Electron/Chromium and node modules
# come with their own licenses (see LICENSE.electron.txt, LICENSES.chromium.html)
LICENSE="AGPL-3+ MIT BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
"
QA_PREBUILT="*"

src_prepare() {
	default

	# prebuilt native modules for other platforms
	local m=resources/app/node_modules/@serialport/bindings-cpp/prebuilds
	rm -r ${m}/{android-*,darwin-*,win32-*} ${m}/linux-x64/node.napi.musl.node || die
	find resources/app/node_modules -path '*/prebuilds/*' \
		\( -path '*linux-arm*' -o -path '*linux-ia32*' -o -name '*musl*' \) \
		-exec rm -rf {} + || die
}

src_install() {
	local dir=/opt/snapmaker-luban

	insinto ${dir}
	doins -r .
	fperms 0755 ${dir}/{snapmaker-luban,chrome_crashpad_handler}
	# setuid sandbox helper, used when unprivileged user namespaces
	# are not available
	fperms 4711 ${dir}/chrome-sandbox
	find "${ED}${dir}" -name '*.so*' -type f -exec chmod 0755 {} + || die
	find "${ED}${dir}" -name '*.node' -type f -exec chmod 0755 {} + || die

	dosym -r ${dir}/snapmaker-luban /usr/bin/snapmaker-luban

	newicon -s 64 resources/app/src/app/resources/images/snap-luban-logo-64x64.png \
		snapmaker-luban.png
	make_desktop_entry snapmaker-luban "Snapmaker Luban" snapmaker-luban \
		"Graphics;3DGraphics;Engineering;" "StartupWMClass=snapmaker-luban"
}

pkg_postinst() {
	xdg_pkg_postinst

	ewarn "Snapmaker Luban ${PV} bundles Electron 15 (Chromium 94, 2021), which"
	ewarn "no longer receives security updates. Avoid opening untrusted content."
	elog
	elog "To connect to a machine over USB-serial your user must be able to"
	elog "open the serial device, e.g.: usermod -aG dialout <user>"
}
