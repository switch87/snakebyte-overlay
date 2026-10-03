# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Based on the pipcl-2.ebuild from the ::4nykey overlay,
# with SRC_URI rewritten to plain GitHub (no custom mirrors).

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=standalone
inherit distutils-r1

DESCRIPTION="Python packaging operations (build helper used by MuPDF/PyMuPDF)"
HOMEPAGE="https://github.com/ArtifexSoftware/pipcl"
SRC_URI="https://github.com/ArtifexSoftware/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
