# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )
inherit distutils-r1 pypi

DESCRIPTION="Asyncio high level UDP sockets"
HOMEPAGE="
	https://github.com/eerimoq/asyncudp
	https://pypi.org/project/asyncudp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# tests in sdist need a network loopback and pytest-asyncio setup not
# shipped upstream; run from git checkout if needed
RESTRICT="test"
