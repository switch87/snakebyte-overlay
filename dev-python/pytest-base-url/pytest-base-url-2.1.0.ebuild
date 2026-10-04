# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="pytest plugin for URL based testing"
HOMEPAGE="
	https://github.com/pytest-dev/pytest-base-url
	https://pypi.org/project/pytest-base-url/
"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pytest-7.0.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.9[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/hatch-vcs[${PYTHON_USEDEP}]"
