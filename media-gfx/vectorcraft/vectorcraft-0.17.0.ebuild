# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (release workflow)
CRAFT_FONTS_COMMIT="a71c20e30af613287c504f7e685ca8fad77752bc"
RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;82a24b006eefa036b43c09a67fb9a3fbd17ffe63;craft-libs-%commit%/crates/docpath'
	[craft-keymap]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/crates/keymap'
	[craft-pdf]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/crates/pdf'
	[craft-print]='https://github.com/storytold/craft-libs;d991bf6792f8ade99c51358bf3c1d902c8cd96b5;craft-libs-%commit%/crates/print'
	[craft-ui]='https://github.com/storytold/craft-libs;5c874d51eeb3de70e735c8ce87a59a7dedd47675;craft-libs-%commit%/crates/ui'
	[craft-window]='https://github.com/storytold/craft-libs;1f805378d454dac48b5c214029d254055fdf961b;craft-libs-%commit%/crates/window'
	[hayro-cmap]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/hayro-cmap'
	[hayro-interpret]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/hayro-interpret'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-postscript]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/hayro-postscript'
	[hayro-syntax]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/hayro-syntax'
	[krilla]='https://github.com/storytold/craft-libs;2eca9b3a53a98ac52efed2a27353c6a6927ead10;craft-libs-%commit%/vendor/krilla'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source vector illustration editor (SVG, PDF), written in Rust"
HOMEPAGE="https://getartcraft.com/apps/vectorcraft https://github.com/storytold/vectorcraft"
SRC_URI="
	https://github.com/storytold/vectorcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	cjk? (
		https://github.com/storytold/craft-fonts/archive/${CRAFT_FONTS_COMMIT}.tar.gz
			-> craft-fonts-${CRAFT_FONTS_COMMIT:0:12}.tar.gz
	)
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 ) cjk? ( OFL-1.1 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 IJG ISC MIT MPL-2.0 OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/vectorcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/vectorcraft usr/bin/vectorcraft-cli"

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

src_configure() {
	# Embed the fonts like the official releases do; without them the app
	# falls back to the system fonts.
	use cjk && export CRAFT_FONTS_DIR="${WORKDIR}/craft-fonts-${CRAFT_FONTS_COMMIT}" CRAFT_FONTS_REQUIRED=1
	cargo_src_configure
}

src_compile() {
	cargo_src_compile -p vectorcraft -p vectorcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{vectorcraft,vectorcraft-cli}

	local id=ai.storyteller.vectorcraft
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
	if use cjk; then
		local lic
		for lic in "${WORKDIR}"/craft-fonts-${CRAFT_FONTS_COMMIT}/fonts/*/OFL.txt; do
			newdoc "${lic}" "OFL-$(basename "$(dirname "${lic}")").txt"
		done
	fi
}
