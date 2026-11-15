# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

# Since 2.x the OpenAPI spec for the mock server ships in the tarball
# (scripts/mock-spec.json.gz) instead of on storage.googleapis.com.
STAINLESS_SPEC_FILE=scripts/mock-spec.json.gz
# See https://github.com/anthropics/anthropic-sdk-python/blob/main/scripts/mock
STAINLESS_MOCK_SERVER_VERSION=0.22.2
STAINLESS_MOCK_SERVER_PACKAGE_JSON="${FILESDIR}/${PN}-2.8.0-mock-server-package.json"

inherit distutils-r1 optfeature stainless-python

MY_PN="anthropic-sdk-python"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="The official Python library for the anthropic API"
HOMEPAGE="
	https://github.com/anthropics/anthropic-sdk-python
	https://pypi.org/project/anthropic
"
SRC_URI+="
	https://github.com/anthropics/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}"

# MIT; vendored httpx_aiohttp (src/anthropic/_vendor): BSD
LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/anyio-4.1.0[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.15[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.0.0[${PYTHON_USEDEP}]
	<dev-python/httpx2-3[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.4.0[${PYTHON_USEDEP}]
	<dev-python/jiter-1[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.1.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-api-2[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
"

BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
	test? (
		dev-python/aiohttp[${PYTHON_USEDEP}]
		>=dev-python/boto3-1.28.57[${PYTHON_USEDEP}]
		>=dev-python/botocore-1.31.57[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/opentelemetry-sdk[${PYTHON_USEDEP}]
		>=dev-python/rich-13.7.1[${PYTHON_USEDEP}]
		>=dev-python/standardwebhooks-1.0.1[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=(
	dirty-equals
	http-snapshot
	inline-snapshot
	pytest-{asyncio,xdist}
	respx
	time-machine
)
distutils_enable_tests pytest

pkg_postinst() {
	optfeature "alternative async HTTP client support" \
		">=dev-python/aiohttp-3.10.0"
	optfeature "Google Cloud Vertex AI integration" \
		">=dev-python/google-auth-2 dev-python/requests"
	optfeature "Amazon Web Services (AWS) Bedrock integration" \
		">=dev-python/boto3-1.28.57 >=dev-python/botocore-1.31.57"
	optfeature "Model Context Protocol (MCP) support" \
		">=dev-python/mcp-1.0"
	optfeature "webhook signature verification" \
		">=dev-python/standardwebhooks-1.0.1"
}
