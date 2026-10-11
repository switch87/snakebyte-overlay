# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 optfeature pypi

DESCRIPTION="Ruida Protocol Analyzer - parse, decode and drive Ruida laser controllers"
HOMEPAGE="
	https://github.com/StevenIsaacs/ruida-pa
	https://pypi.org/project/ruida-pa/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Upstream also lists bokeh (plotting) and textual (TUI) as hard
# dependencies, but they are only imported by the interactive analyzer
# tools; the driver/RPyC client used by rayforge only needs these.
RDEPEND="
	>=dev-python/pyserial-3.5[${PYTHON_USEDEP}]
	>=dev-python/rpyc-6.0[${PYTHON_USEDEP}]
"

pkg_postinst() {
	optfeature "the rpa-script terminal UI" dev-python/textual
	elog "Plotting in the 'rpa' analyzer needs dev-python/bokeh, which is"
	elog "not packaged; the Ruida driver used by rayforge works without it."
}
