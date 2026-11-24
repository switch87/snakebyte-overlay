# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-atomic]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/atomic'
	[craft-cfb]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/cfb'
	[craft-cms]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/cms'
	[craft-codepage]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/codepage'
	[craft-csv]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/csv'
	[craft-dds]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/dds'
	[craft-designcraft-format]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/designcraft-format'
	[craft-dialogs]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/dialogs'
	[craft-docpath]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/docpath'
	[craft-document-bundle]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/document-bundle'
	[craft-docx]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/docx'
	[craft-drawingml]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/drawingml'
	[craft-eps]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/eps'
	[craft-epub]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/epub'
	[craft-file-formats]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/file-formats'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/fonts-build'
	[craft-i18n]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/i18n'
	[craft-idml]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/idml'
	[craft-image-codecs]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/image-codecs'
	[craft-indd]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/indd'
	[craft-jpeg]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/jpeg'
	[craft-keymap]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/keymap'
	[craft-math]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/math'
	[craft-mcp-server]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/mcp-server'
	[craft-metadata]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/metadata'
	[craft-mime]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/mime'
	[craft-offcrypto]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/offcrypto'
	[craft-opc]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/opc'
	[craft-pdf]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/pdf'
	[craft-pptx]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/pptx'
	[craft-prepress]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/prepress'
	[craft-print]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/print'
	[craft-ps]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/ps'
	[craft-psd]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/psd'
	[craft-rtf]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/rtf'
	[craft-sheet]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/sheet'
	[craft-svg]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/svg'
	[craft-tiff]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/tiff'
	[craft-ui]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/update'
	[craft-window]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/window'
	[craft-winprint-gdi]='https://github.com/storytold/winprint.rs;64e7afd4d1483512385012c340ecaaaf0f3beb7f;winprint.rs-%commit%/crates/gdi'
	[craft-wordmodel]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/wordmodel'
	[craft-xlsx]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/xlsx'
	[craft-xml]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/xml'
	[craft-zip]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/crates/zip'
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
	[hayro-cmap]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro-cmap'
	[hayro-interpret]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro-interpret'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-postscript]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro-postscript'
	[hayro-syntax]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro-syntax'
	[hayro]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/hayro'
	[indd]='https://github.com/storytold/indd-utils;7f3060e5bce78d21ea70e0d5eacb96edce15dfbe;indd-utils-%commit%'
	[krilla]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/krilla'
	[linesweeper]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/linesweeper'
	[vectorcraft-geom]='https://github.com/storytold/vectorcraft;6b3a6b8788ebcb420d69449199cbdf323888d27e;vectorcraft-%commit%/crates/geom'
	[vectorcraft-pathops]='https://github.com/storytold/vectorcraft;6b3a6b8788ebcb420d69449199cbdf323888d27e;vectorcraft-%commit%/crates/pathops'
	[vello_common]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/vello_common'
	[vello_cpu]='https://github.com/storytold/craft-libs;33be35625e252cc4f06aa375b3b428521faea37d;craft-libs-%commit%/vendor/vello_cpu'
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
	[winprint]='https://github.com/storytold/winprint.rs;8ae097ef941b432b0e7671b1ec3a506800e65e57;winprint.rs-%commit%'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source page layout and print design application, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/designcraft https://github.com/storytold/designcraft"
SRC_URI="
	https://github.com/storytold/designcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 IJG ISC MIT
	MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/designcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/designcraft usr/bin/designcraft-cli"

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

src_compile() {
	cargo_src_compile -p designcraft -p designcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{designcraft,designcraft-cli}

	local id=ai.storyteller.designcraft
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
