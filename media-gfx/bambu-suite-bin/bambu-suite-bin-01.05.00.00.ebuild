# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

# The CDN path contains an upload timestamp that cannot be derived from ${PV}.
# Look it up on https://bambulab.com/en/download/suite (or run
# files/bambu-suite-bump) when bumping.
BUILD_STAMP="20260922_160447_746"
MY_P="Bambu_Suite_Public_Win_${PV}"

DESCRIPTION="Bambu Lab laser and cutting module software (Windows build via Wine)"
HOMEPAGE="https://bambulab.com/en/download/suite"
SRC_URI="https://public-cdn.bblmw.cn/general_pkg/prod/setup/${BUILD_STAMP}/${MY_P}.exe"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	virtual/wine
	x11-libs/libnotify
"
BDEPEND="
	app-arch/innoextract
	media-gfx/icoutils
"

QA_PREBUILT="*"

src_unpack() {
	innoextract --silent --extract --output-dir "${S}" "${DISTDIR}/${MY_P}.exe" \
		|| die "innoextract failed"
}

src_prepare() {
	default

	wrestool -x -t 14 app/BambuSuite.exe -o "${T}/bambu-suite.ico" \
		|| die "extracting icon failed"
	icotool -x -o "${T}" "${T}/bambu-suite.ico" || die "converting icon failed"
}

src_install() {
	local dir=/opt/bambu-suite

	insinto ${dir}
	doins -r app
	insinto ${dir}/redist
	doins tmp/VC_redist.x64.exe
	insinto ${dir}/fonts
	doins autofonts/*.ttf

	newbin "${FILESDIR}"/bambu-suite bambu-suite

	local png size
	for png in "${T}"/bambu-suite_*x32.png; do
		size=$(basename "${png}" | sed -E 's/.*_([0-9]+)x[0-9]+x32\.png/\1/')
		newicon -s ${size} "${png}" bambu-suite.png
	done

	make_desktop_entry bambu-suite "Bambu Suite" bambu-suite "Graphics;Engineering;" \
		"StartupWMClass=bambusuite.exe"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Start Bambu Suite with 'bambu-suite' or from the application menu."
	elog "On first start a per-user Wine prefix is created in"
	elog "  \${XDG_DATA_HOME:-~/.local/share}/bambu-suite/prefix"
	elog "(override with BAMBU_SUITE_WINEPREFIX). Remove that directory to reset."
}
