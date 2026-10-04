# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_P="LightBurn-v${PV}"

DESCRIPTION="Layout, editing and control software for laser cutters (Windows build via Wine)"
HOMEPAGE="https://lightburnsoftware.com/"
SRC_URI="https://release.lightburnsoftware.com/LightBurn/Release/${MY_P}/${MY_P}.exe"
S="${WORKDIR}"

LICENSE="all-rights-reserved GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	virtual/wine
	x11-libs/libnotify
"
BDEPEND="
	app-arch/innoextract
	dev-util/mingw64-toolchain
	media-gfx/icoutils
"

QA_PREBUILT="*"

src_unpack() {
	innoextract --silent --extract --output-dir "${S}" "${DISTDIR}/${MY_P}.exe" \
		|| die "innoextract failed"
}

src_prepare() {
	default

	cp "${FILESDIR}"/winrt-capture-stub.c "${S}"/ || die
	icotool -x -o "${T}" app/lightburn.ico || die
}

src_compile() {
	local -x PATH="${BROOT}/usr/lib/mingw64-toolchain/bin:${PATH}"
	x86_64-w64-mingw32-gcc -shared -O2 -Wall -Wno-incompatible-pointer-types \
		-o winrt-capture-stub.dll winrt-capture-stub.c || die
}

src_install() {
	local dir=/opt/lightburn-wine

	# Windows-only drivers; the VC++ runtimes go to the prefix at first start
	rm -r app/{EzCadDriver,FTDI_Driver.exe,vc_redist.x64.exe} || die

	insinto ${dir}/redist
	doins app/vcredist_{2010,2015-2022}_x64.exe
	rm app/vcredist_{2010,2015-2022}_x64.exe || die

	insinto ${dir}
	doins -r app
	doins winrt-capture-stub.dll

	newbin "${FILESDIR}"/lightburn-wine lightburn-wine

	local png size
	for png in "${T}"/lightburn_*x32.png; do
		size=$(basename "${png}" | sed -E 's/.*_([0-9]+)x[0-9]+x32\.png/\1/')
		newicon -s ${size} "${png}" lightburn-wine.png
	done
	make_desktop_entry lightburn-wine "LightBurn (Wine)" lightburn-wine \
		"Graphics;Engineering;" "StartupWMClass=lightburn.exe"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "LightBurn ${PV} is not supported on Linux by LightBurn Software;"
	elog "this package runs the Windows build under Wine. Start it with"
	elog "'lightburn-wine'. A per-user Wine prefix is created on first start in"
	elog "  \${XDG_DATA_HOME:-~/.local/share}/lightburn-wine/prefix"
	elog "(override with LIGHTBURN_WINEPREFIX); settings of a native LightBurn"
	elog "1.x (~/.config/LightBurn/prefs.ini) are copied there once."
	elog
	elog "Known limitations:"
	elog "- camera support is disabled (Wine lacks the WinRT capture APIs)"
	elog "- LightBurn 2.x needs a license whose update period covers ${PV}"
	elog "- serial lasers appear as COM ports; your user needs access to the"
	elog "  device, e.g.: usermod -aG dialout <user>"
}
