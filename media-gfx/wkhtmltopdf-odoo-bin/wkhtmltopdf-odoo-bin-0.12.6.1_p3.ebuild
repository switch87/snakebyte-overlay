# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

MY_PV="$(ver_cut 1-4)-$(ver_cut 6)"

DESCRIPTION="wkhtmltopdf with patched Qt, the build required by Odoo for PDF reports"
HOMEPAGE="
	https://wkhtmltopdf.org/
	https://github.com/wkhtmltopdf/packaging
	https://github.com/odoo/odoo/wiki/Wkhtmltopdf
"
SRC_URI="https://github.com/wkhtmltopdf/packaging/releases/download/${MY_PV}/wkhtmltox_${MY_PV}.bookworm_amd64.deb"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="mirror strip"

# Statically built against a patched Qt 4; needs only these system libraries
# (as listed by the upstream Debian bookworm package).
RDEPEND="
	app-misc/ca-certificates
	dev-libs/openssl:0/3
	media-fonts/font-misc-misc
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libjpeg-turbo
	media-libs/libpng:0/16
	virtual/zlib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/libxcb
"

# Odoo needs exactly this "with patched qt" release for headers, footers and
# page numbering in reports; the unpatched wkhtmltopdf does not work.
QA_PREBUILT="usr/bin/* usr/lib*/libwkhtmltox.so*"

src_prepare() {
	default
	gunzip usr/local/share/man/man1/*.1.gz || die
}

src_install() {
	# upstream installs into /usr/local
	dobin usr/local/bin/wkhtmlto{pdf,image}
	dolib.so usr/local/lib/libwkhtmltox.so.0.12.6
	local l
	for l in libwkhtmltox.so{.0.12,.0,}; do
		dosym libwkhtmltox.so.0.12.6 /usr/$(get_libdir)/${l}
	done
	insinto /usr/include
	doins -r usr/local/include/wkhtmltox
	doman usr/local/share/man/man1/*.1
}
