# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Based on the pymupdf-fonts-1.0.4.ebuild from the ::4nykey overlay.
# 1.0.5 was only published as an sdist on PyPI (no GitHub tag).

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Collection of optional fonts for PyMuPDF"
HOMEPAGE="https://github.com/pymupdf/pymupdf-fonts"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
