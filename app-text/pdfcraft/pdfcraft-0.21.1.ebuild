# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/docpath'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/fonts-build'
	[craft-i18n]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/i18n'
	[craft-keymap]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/keymap'
	[craft-menu]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/menu'
	[craft-print]='https://github.com/storytold/craft-libs;60ede99985ef1e5df87a2aca66ed538eb23dec99;craft-libs-%commit%/crates/print'
	[craft-quit]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/quit'
	[craft-ui]='https://github.com/storytold/craft-libs;787a7a0f972fd1d7a7618fdbeca3a5267a0407ff;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;6e03f65bf45181db77ba6229716e6624db9eb25b;craft-libs-%commit%/crates/update'
	[craft-web-api]='https://github.com/storytold/craft-libs;fd5e2feff6ea25bed371a99cc732b3968d621505;craft-libs-%commit%/crates/web-api'
	[craft-web-host]='https://github.com/storytold/craft-libs;fd5e2feff6ea25bed371a99cc732b3968d621505;craft-libs-%commit%/crates/web-host'
	[craft-winprint-gdi]='https://github.com/storytold/winprint.rs;64e7afd4d1483512385012c340ecaaaf0f3beb7f;winprint.rs-%commit%/crates/gdi'
	[ecolor]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/ecolor'
	[eframe]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/eframe'
	[egui-wgpu]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui-wgpu'
	[egui-winit]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui-winit'
	[egui]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui'
	[egui_extras]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui_extras'
	[egui_glow]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui_glow'
	[egui_kittest]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/egui_kittest'
	[emath]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/emath'
	[epaint]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/epaint'
	[epaint_default_fonts]='https://github.com/storytold/egui;725a39fca940f77149ffbb9c58eef405a16997bc;egui-%commit%/crates/epaint_default_fonts'
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
	[winprint]='https://github.com/storytold/winprint.rs;5f80b9baf6b58937c401656634e42d33f00ddf49;winprint.rs-%commit%'
	[winprint]='https://github.com/storytold/winprint.rs;bc06a7c48b768eb27a828c7986f6d2868b245ee0;winprint.rs-%commit%'
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
