# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;82a24b006eefa036b43c09a67fb9a3fbd17ffe63;craft-libs-%commit%/crates/docpath'
	[craft-print]='https://github.com/storytold/craft-libs;666c358065261a2816b376fa3bb10538dbf53040;craft-libs-%commit%/crates/print'
	[craft-quit]='https://github.com/storytold/craft-libs;f58bc1a3df490992d633393d0898af0588ce882c;craft-libs-%commit%/crates/quit'
	[craft-ui]='https://github.com/storytold/craft-libs;5c874d51eeb3de70e735c8ce87a59a7dedd47675;craft-libs-%commit%/crates/ui'
	[winprint]='https://github.com/storytold/winprint.rs;5f80b9baf6b58937c401656634e42d33f00ddf49;winprint.rs-%commit%'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source PDF reader and editor, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/pdfcraft https://github.com/storytold/pdfcraft"
SRC_URI="
	https://github.com/storytold/pdfcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 ISC MIT OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+mcp"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!app-text/pdfcraft-bin
	media-libs/libglvnd
	media-libs/vulkan-loader
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	dev-libs/wayland
"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/pdfcraft usr/bin/pdfcraft-cli"

src_configure() {
	# The MCP server for AI agents (`pdfcraft-cli mcp`) is the CLI's only default feature.
	cargo_src_configure $(usev !mcp --no-default-features)
}

src_compile() {
	cargo_src_compile -p pdfcraft -p pdfcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{pdfcraft,pdfcraft-cli}

	local id=ai.storyteller.pdfcraft
	domenu packaging/linux/${id}.desktop
	insinto /usr/share/mime/packages
	newins packaging/linux/${id}.mime.xml ${id}.xml
	sed -e "s/@VERSION@/${PV}/g" -e "s/@DATE@/$(date -u +%F)/g" \
		packaging/linux/${id}.metainfo.xml.in > "${T}"/${id}.metainfo.xml || die
	insinto /usr/share/metainfo
	doins "${T}"/${id}.metainfo.xml
	insinto /usr/share/icons
	doins -r assets/app-icon/hicolor

	dodoc README.md
}
