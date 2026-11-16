# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (release workflow)
CRAFT_FONTS_COMMIT="b076417b5880bd4154bd22f00695b1d28c6bea83"
RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/docpath'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;bb8320f5fa5d20fa78a026d0de06fe4e2f08a099;craft-libs-%commit%/crates/fonts-build'
	[craft-i18n]='https://github.com/storytold/craft-libs;bb8320f5fa5d20fa78a026d0de06fe4e2f08a099;craft-libs-%commit%/crates/i18n'
	[craft-keymap]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/keymap'
	[craft-pdf]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/pdf'
	[craft-print]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/print'
	[craft-proof]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/proof'
	[craft-ui]='https://github.com/storytold/craft-libs;bb8320f5fa5d20fa78a026d0de06fe4e2f08a099;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;6e03f65bf45181db77ba6229716e6624db9eb25b;craft-libs-%commit%/crates/update'
	[craft-vectorcraft-format]='https://github.com/storytold/craft-libs;6e03f65bf45181db77ba6229716e6624db9eb25b;craft-libs-%commit%/crates/vectorcraft-format'
	[craft-web-api]='https://github.com/storytold/craft-libs;fd5e2feff6ea25bed371a99cc732b3968d621505;craft-libs-%commit%/crates/web-api'
	[craft-window]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/crates/window'
	[craft-winprint-gdi]='https://github.com/storytold/winprint.rs;417ac3c4d14d3da5485a99c7d5ce8f05664ec312;winprint.rs-%commit%/crates/gdi'
	[ecolor]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/ecolor'
	[eframe]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/eframe'
	[egui-wgpu]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui-wgpu'
	[egui-winit]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui-winit'
	[egui]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui'
	[egui_extras]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui_extras'
	[egui_glow]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui_glow'
	[egui_kittest]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/egui_kittest'
	[emath]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/emath'
	[epaint]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/epaint'
	[epaint_default_fonts]='https://github.com/storytold/egui;6d518fc799681571963842f95b55a6b68431b15a;egui-%commit%/crates/epaint_default_fonts'
	[hayro-cmap]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/hayro-cmap'
	[hayro-interpret]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/hayro-interpret'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-postscript]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/hayro-postscript'
	[hayro-syntax]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/hayro-syntax'
	[krilla]='https://github.com/storytold/craft-libs;9be9a63782298ab59cd9b7a42ee9cba4f42a5ccb;craft-libs-%commit%/vendor/krilla'
	[linesweeper]='https://github.com/storytold/craft-libs;481f66d287b2a06845f3667a19daf35f0fe958ed;craft-libs-%commit%/vendor/linesweeper'
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
	[winprint]='https://github.com/storytold/winprint.rs;5f80b9baf6b58937c401656634e42d33f00ddf49;winprint.rs-%commit%'
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
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 IJG ISC MIT
	MPL-2.0 Unicode-3.0 ZLIB
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
	# [patch] wins over Cargo.toml's). pycargoebuild only lists the git crates the app
	# itself uses, but cargo loads every patched crate the workspace lock knows: find
	# those in the already unpacked tarball of the same repository and commit.
	local crate uri commit dir line url rev k base found
	{
		echo "[patch.crates-io]"
		for crate in $(sed -n '/^\[patch\.crates-io\]/,/^\[/s/^\([A-Za-z0-9_-]\+\) *= *{.*git *=.*/\1/p' Cargo.toml); do
			if [[ -n ${GIT_CRATES[${crate}]} ]]; then
				IFS=';' read -r uri commit dir _ <<< "${GIT_CRATES[${crate}]}"
				dir=${dir:-${crate}-%commit%}
				echo "${crate} = { path = \"${WORKDIR}/${dir//%commit%/${commit}}\" }"
				continue
			fi
			line=$(sed -n "/^\[patch\.crates-io\]/,/^\[/{/^${crate} *=/p}" Cargo.toml)
			url=$(sed -n 's/.*git *= *"\([^"]*\)".*/\1/p' <<< "${line}")
			rev=$(sed -n 's/.*rev *= *"\([^"]*\)".*/\1/p' <<< "${line}")
			found=
			for k in "${!GIT_CRATES[@]}"; do
				IFS=';' read -r uri commit dir _ <<< "${GIT_CRATES[${k}]}"
				[[ ${uri%.git} == "${url%.git}" && ${commit} == "${rev}" ]] || continue
				base=${dir:-${k}-%commit%}
				base=${WORKDIR}/${base%%/*}
				base=${base//%commit%/${commit}}
				found=$(grep -rlE --include=Cargo.toml "^name *= *\"${crate}\"" "${base}" | head -n1)
				break
			done
			if [[ -n ${found} ]]; then
				echo "${crate} = { path = \"${found%/Cargo.toml}\" }"
			else
				einfo "${crate}: patched from git but not fetched, skipped"
			fi
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
