# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{10..14} )

inherit distutils-r1 pypi
#
# Eclasses tend to list descriptions of how to use their functions properly.
# Take a look at the eclass/ directory for more examples.

# Short one-line description of this package.
DESCRIPTION="Python Binding of SOLVESPACE Constraint Solver"
HOMEPAGE="https://github.com/realthunder/slvs_py"
SRC_URI="$(pypi_sdist_url "${PN^}" "${PV}")"

#S=${WORKDIR}/${P^}

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
${PYTHON_DEPS}
"
DEPEND="
${RDEPEND}
dev-python/scikit-build
"
BDEPEND="dev-lang/swig
dev-python/scikit-build
virtual/pkgconfig"

python_prepare_all() {
	find "${S}/${PN/-/_}/extlib" -mindepth 1 -delete
# We can't rely on PATCHES because order counts
	pushd "${S}/${PN/-/_}" || die
	eapply "${FILESDIR}/${PV}-CMake-remove-deprecated.patch"
	sed	-e '/include(GetGitCommitHash)/ s/^/#/' \
		-e '/^# set(GIT_COMMIT_HASH/ s/^#//' \
		-i CMakeLists.txt || die
	sed -e "s/Python3 REQUIRED/Python3 ${EPYTHON:7} EXACT REQUIRED/" \
	-i "src/swig/python/CMakeLists.txt" || die
	popd || die
	distutils-r1_python_prepare_all
}
