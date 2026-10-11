# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="The essential to control music from your SONOS devices on Linux platforms"
HOMEPAGE="https://janbar.github.io/noson-app/index.html"
SRC_URI="https://github.com/janbar/noson-app/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# libnoson is bundled in the source tarball (backend/lib) and linked
# statically; it picks up PulseAudio and FLAC from the system.
DEPEND="
	dev-libs/openssl:=
	>=dev-qt/qtbase-6.9:6[dbus,gui,network,ssl,widgets,xml]
	>=dev-qt/qtdeclarative-6.9:6
	>=dev-qt/qtsvg-6.9:6
	>=dev-qt/qt5compat-6.9:6
	media-libs/flac:=[cxx]
	media-libs/libpulse
	virtual/zlib:=
"
RDEPEND="
	${DEPEND}
	dev-qt/qttranslations:6
"

src_configure() {
	local mycmakeargs=(
		-DQT_VERSION_PREFERRED=6
		-DBUILD_DEPENDENCIES=OFF
	)
	cmake_src_configure
}
