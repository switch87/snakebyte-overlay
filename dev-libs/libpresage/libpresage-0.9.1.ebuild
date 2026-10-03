# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

SRC_URI="https://sourceforge.net/projects/presage/files/presage/${PV}/presage-${PV}.tar.gz"
DESCRIPTION="An intelligent predictive text entry system"
HOMEPAGE="https://presage.sourceforge.io"
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
RESTRICT="test"

DEPEND="
    dev-db/sqlite
    dev-libs/tinyxml
"

RDEPEND="${DEPEND}"

BDEPEND="
    dev-build/automake-wrapper
    dev-build/automake
"

S="${WORKDIR}/presage-${PV}"

src_prepare() {
    eapply "${FILESDIR}/001-gcc6.patch"
    eapply "${FILESDIR}/002-gcc11.patch"
    eapply "${FILESDIR}/libpresage-0.9.1-disable-gtk-apps.patch"
    eapply_user
    eautoreconf
}

PATCHES=(
    "${FILESDIR}/libpresage-0.9.1-disable-gtk-configure.patch"
#    "${FILESDIR}/libpresage-0.9.1-disable-gtk-apps-makefilein.patch"
#    "${FILESDIR}/libpresage-0.9.1-disable-gtk-apps.patch"
)

