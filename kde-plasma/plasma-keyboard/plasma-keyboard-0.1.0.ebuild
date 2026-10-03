# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QTMIN=6.10.1
inherit cmake-utils #kde-plasma

DESCRIPTION="Virtual keyboard for Plasma"
HOMEPAGE="https://kde.org/plasma-desktop/"
EGIT_REPO_URI="https://github.com/KDE/plasma-keyboard.git"
SRC_URI="https://github.com/KDE/plasma-keyboard/archive/v${PV}.tar.gz -> ${P}.tar.gz"


LICENSE="|| ( LGPL-2.1-only LGPL-3.0-only LicenseRef-KDE-Accepted-LGPL ) BSD-2-Clause BSD-3-Clause"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE=""

RDEPEND="
	dev-libs/wayland
    >=dev-qt/qtbase-${QTMIN}:6=[gui,wayland]
	>=dev-qt/qtdeclarative-${QTMIN}:6
    >=dev-qt/qtvirtualkeyboard-${QTMIN}:6
    >=kde-frameworks/kcmutils:6
    >=kde-frameworks/kconfig:6
    >=kde-frameworks/kcoreaddons:6
    >=kde-frameworks/ki18n:6
"
DEPEND="${RDEPEND}
    >=dev-libs/wayland-protocols-1.19
"
BDEPEND="
    dev-util/wayland-scanner
"


src_configure() {
    local mycmakeargs=(
        -DBUILD_TESTING=OFF
    )
    cmake_src_configure
}

