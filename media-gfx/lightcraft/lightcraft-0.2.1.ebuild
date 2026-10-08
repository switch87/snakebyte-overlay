# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

inherit cargo desktop xdg

DESCRIPTION="Open-source photo organiser and raw developer, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/lightcraft https://github.com/storytold/lightcraft"
SRC_URI="
	https://github.com/storytold/lightcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 IJG ISC MIT UoI-NCSA OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+avif +jpegxl"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/lightcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/lightcraft usr/bin/lightcraft-cli"

src_prepare() {
	default
	# lightcraft-codecs enables avif and jxl by default and every crate inherits the
	# workspace dependency; turn the defaults off so the USE flags decide.
	local dep='lightcraft-codecs = { path = "crates/codecs"'
	sed -i "s|^${dep} }|${dep}, default-features = false }|" Cargo.toml || die
	grep -q 'crates/codecs", default-features = false' Cargo.toml || die "Cargo.toml changed"
}

src_configure() {
	local myfeatures=(
		lightcraft-codecs/parallel
		$(usev avif lightcraft-codecs/avif)
		$(usev jpegxl lightcraft-codecs/jxl)
	)
	cargo_src_configure
}

src_compile() {
	cargo_src_compile -p lightcraft -p lightcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{lightcraft,lightcraft-cli}

	local id=ai.storyteller.lightcraft
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
