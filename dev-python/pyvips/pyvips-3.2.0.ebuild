# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{11..14} )
inherit distutils-r1 pypi toolchain-funcs

DESCRIPTION="Python binding for the libvips image processing library"
HOMEPAGE="
	https://github.com/libvips/pyvips
	https://pypi.org/project/pyvips/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# media-libs/vips is needed at build time for API-mode cffi extension
# (setup.py silently falls back to slower ABI mode without the headers)
DEPEND="media-libs/vips"
RDEPEND="
	${DEPEND}
	dev-python/cffi[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/pkgconfig[${PYTHON_USEDEP}]
	virtual/pkgconfig
"

distutils_enable_tests pytest

src_configure() {
	# fail loudly instead of falling back to ABI mode
	if ! "$(tc-getPKG_CONFIG 2>/dev/null || echo pkg-config)" --exists vips; then
		die "vips.pc not found - API mode build would silently degrade to ABI mode"
	fi
}
