# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/crates/docpath'
	[craft-pdf]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/crates/pdf'
	[craft-ui]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/crates/ui'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-syntax]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/vendor/hayro-syntax'
	[krilla]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/vendor/krilla'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source 2D CAD drafting application, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/cadcraft https://github.com/storytold/cadcraft"
SRC_URI="
	https://github.com/storytold/cadcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/cadcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/cadcraft usr/bin/cadcraft-cli"

src_prepare() {
	default
	# Cargo.toml's [patch.crates-io] points crates at git; the eclass only patches the
	# git URLs, so send those crates to the unpacked GIT_CRATES too (the cargo config's
	# [patch] wins over Cargo.toml's).
	local crate uri commit dir
	{
		echo "[patch.crates-io]"
		for crate in $(sed -n '/^\[patch\.crates-io\]/,/^\[/s/^\([A-Za-z0-9_-]\+\) *= *{.*git *=.*/\1/p' Cargo.toml); do
			IFS=';' read -r uri commit dir _ <<< "${GIT_CRATES[${crate}]}"
			[[ -n ${commit} ]] || die "${crate} is patched from git but not in GIT_CRATES"
			dir=${dir:-${crate}-%commit%}
			echo "${crate} = { path = \"${WORKDIR}/${dir//%commit%/${commit}}\" }"
		done
	} >> "${ECARGO_HOME}"/config.toml || die
}

src_compile() {
	cargo_src_compile -p cadcraft -p cadcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{cadcraft,cadcraft-cli}

	local id=ai.storyteller.cadcraft
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
