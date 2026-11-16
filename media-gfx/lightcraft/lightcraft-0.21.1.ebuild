# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-crw]='https://github.com/storytold/craft-libs;f3b62ec61f45534392376492fc5ad33047375205;craft-libs-%commit%/crates/crw'
	[craft-docpath]='https://github.com/storytold/craft-libs;c5a1cbfb5f9049f9270955caffb5bee5997aebf7;craft-libs-%commit%/crates/docpath'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;c5a1cbfb5f9049f9270955caffb5bee5997aebf7;craft-libs-%commit%/crates/fonts-build'
	[craft-i18n]='https://github.com/storytold/craft-libs;c5a1cbfb5f9049f9270955caffb5bee5997aebf7;craft-libs-%commit%/crates/i18n'
	[craft-tiff]='https://github.com/storytold/craft-libs;3b3104981bb3093904a12e44d6a3b41c6c4c39c8;craft-libs-%commit%/crates/tiff'
	[craft-ui]='https://github.com/storytold/craft-libs;c5a1cbfb5f9049f9270955caffb5bee5997aebf7;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;6e03f65bf45181db77ba6229716e6624db9eb25b;craft-libs-%commit%/crates/update'
	[craft-window]='https://github.com/storytold/craft-libs;c5a1cbfb5f9049f9270955caffb5bee5997aebf7;craft-libs-%commit%/crates/window'
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
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
)

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
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 IJG ISC MIT
	MPL-2.0 UoI-NCSA Unicode-3.0 ZLIB
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
