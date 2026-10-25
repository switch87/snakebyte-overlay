# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (release workflow)
CRAFT_FONTS_COMMIT="43913056ce82a3fdad0ef69f6b88d1dc922a8104"
RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-media]='https://github.com/storytold/craft-libs;f0ad6c1e1d297908915f4be315b0fcfc9be7b5d4;craft-libs-%commit%/crates/media'
	[craft-pdf]='https://github.com/storytold/craft-libs;9f75d3dc19b4b514c4f3d4847ed1ec1b0e86b4ef;craft-libs-%commit%/crates/pdf'
	[krilla]='https://github.com/storytold/craft-libs;9f75d3dc19b4b514c4f3d4847ed1ec1b0e86b4ef;craft-libs-%commit%/vendor/krilla'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source presentation and slide show application, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/deckcraft https://github.com/storytold/deckcraft"
SRC_URI="
	https://github.com/storytold/deckcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
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
	Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk +pipewire"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
# Sound goes through ALSA's "default" device; on a PipeWire system that needs
# PipeWire's ALSA config in /etc/alsa/conf.d (USE=pipewire-alsa).
RDEPEND="
	!app-office/deckcraft-bin
	media-libs/alsa-lib
	pipewire? ( media-video/pipewire[pipewire-alsa] )
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
DEPEND="
	media-libs/alsa-lib
"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/deckcraft usr/bin/deckcraft-cli"

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
	cargo_src_compile -p deckcraft -p deckcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{deckcraft,deckcraft-cli}

	local id=ai.storyteller.deckcraft
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
