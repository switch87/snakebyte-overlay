# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="pytest plugin to write end-to-end browser tests with Playwright"
HOMEPAGE="
	https://github.com/microsoft/playwright-pytest
	https://pypi.org/project/pytest-playwright/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/playwright-1.18[${PYTHON_USEDEP}]
	>=dev-python/pytest-6.2.4[${PYTHON_USEDEP}]
	<dev-python/pytest-10[${PYTHON_USEDEP}]
	>=dev-python/pytest-base-url-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/python-slugify-6.0.0[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/setuptools-scm[${PYTHON_USEDEP}]"
