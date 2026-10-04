# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python library to automate Chromium, Firefox and WebKit browsers"
HOMEPAGE="
	https://playwright.dev/python/
	https://github.com/microsoft/playwright-python
	https://pypi.org/project/playwright/
"
# Upstream only publishes platform wheels; the sdist downloads the
# Node.js-based driver at build time. The wheel bundles that driver.
SRC_URI="$(pypi_wheel_url ${PN} ${PV} py3 none-manylinux1_x86_64)"
S=${WORKDIR}

# playwright: Apache-2.0; bundled driver: Node.js (MIT and others)
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	>=dev-python/greenlet-3.1.1[${PYTHON_USEDEP}]
	=dev-python/pyee-13*[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3*/site-packages/playwright/driver/*"

src_unpack() {
	:
}

python_compile() {
	distutils_wheel_install "${BUILD_DIR}/install" \
		"${DISTDIR}/$(pypi_wheel_name ${PN} ${PV} py3 none-manylinux1_x86_64)"
	# the wheel installer drops the executable bit of the bundled node
	chmod +x "${BUILD_DIR}"/install/usr/lib/python*/site-packages/playwright/driver/node \
		|| die
}

pkg_postinst() {
	elog "Playwright downloads the browsers it drives into"
	elog "~/.cache/ms-playwright; fetch them with e.g.:"
	elog "  python3 -m playwright install chromium"
}
