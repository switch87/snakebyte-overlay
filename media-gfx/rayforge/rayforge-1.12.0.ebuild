# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 xdg

DESCRIPTION="G-code generator and control software for laser cutters and engravers"
HOMEPAGE="
	https://rayforge.org
	https://github.com/barebaric/rayforge
"
SRC_URI="https://github.com/barebaric/${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Python dependencies follow upstream requirements.txt (pins relaxed to
# minimum versions where they matter; upstream pins are pip-style exact
# pins for their CI).
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/asyncudp[${PYTHON_USEDEP}]
		dev-python/blinker[${PYTHON_USEDEP}]
		dev-python/ezdxf[${PYTHON_USEDEP}]
		dev-python/gitpython[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/platformdirs[${PYTHON_USEDEP}]
		dev-python/pluggy[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[cairo,${PYTHON_USEDEP}]
		>=dev-python/PyMuPDF-1.28.2[${PYTHON_USEDEP}]
		dev-python/pyopengl[${PYTHON_USEDEP}]
		dev-python/pyopengl-accelerate[${PYTHON_USEDEP}]
		dev-python/pypdf[${PYTHON_USEDEP}]
		dev-python/pyserial[${PYTHON_USEDEP}]
		dev-python/pyvips[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		>=dev-python/raydriver-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/raygeo-1.58.2[${PYTHON_USEDEP}]
		>=dev-python/ruida-pa-0.21.2[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/semver[${PYTHON_USEDEP}]
		dev-python/svgelements[${PYTHON_USEDEP}]
		dev-python/trimesh[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/vtracer[${PYTHON_USEDEP}]
		dev-python/websockets[${PYTHON_USEDEP}]
		dev-python/zeroconf[${PYTHON_USEDEP}]
		media-libs/opencv[python,${PYTHON_USEDEP}]
	')
	gui-libs/gtk:4[introspection]
	gui-libs/libadwaita:1[introspection]
	gnome-base/librsvg:2[introspection]
	media-libs/graphene[introspection]
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/pango[introspection]
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-mock )
distutils_enable_tests pytest

src_prepare() {
	default

	# Replace setuptools-git-versioning (needs a git checkout) with a
	# static version.
	sed -i \
		-e 's/^dynamic = \["version", "dependencies"\]/version = "'${PV}'"\ndynamic = ["dependencies"]/' \
		-e 's/, "setuptools-git-versioning"//' \
		pyproject.toml || die
	sed -i -e '/^\[tool\.setuptools-git-versioning\]/,+1d' pyproject.toml || die
	if grep -q setuptools-git-versioning pyproject.toml; then
		die "setuptools-git-versioning removal from pyproject.toml failed"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "To talk to a laser over a serial port your user must be able to"
	elog "access the serial device, e.g.:"
	elog "  usermod -aG dialout <user>"
}
