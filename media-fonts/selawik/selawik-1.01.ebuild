# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Microsoft's open-source, metric-compatible fallback for Segoe UI"
HOMEPAGE="https://github.com/microsoft/Selawik"
SRC_URI="https://github.com/microsoft/Selawik/releases/download/${PV}/Selawik_Release.zip -> ${P}.zip"
S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="app-arch/unzip"

FONT_SUFFIX="ttf"
