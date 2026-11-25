# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (release workflow)
CRAFT_FONTS_COMMIT="b076417b5880bd4154bd22f00695b1d28c6bea83"
RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-atomic]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/atomic'
	[craft-cfb]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/cfb'
	[craft-codepage]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/codepage'
	[craft-dds]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/dds'
	[craft-doc-binary]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/doc-binary'
	[craft-docx]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/docx'
	[craft-drawingml]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/drawingml'
	[craft-flow]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/flow'
	[craft-font-catalog]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/font-catalog'
	[craft-font-store]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/font-store'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/fonts-build'
	[craft-html]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/html'
	[craft-i18n]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/i18n'
	[craft-image-codecs]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/image-codecs'
	[craft-jpeg]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/jpeg'
	[craft-latex]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/latex'
	[craft-markdown]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/markdown'
	[craft-math]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/math'
	[craft-mcp-server]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/mcp-server'
	[craft-metadata]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/metadata'
	[craft-metafile]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/metafile'
	[craft-mime]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/mime'
	[craft-odf]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/odf'
	[craft-ods]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/ods'
	[craft-offcrypto]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/offcrypto'
	[craft-opc]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/opc'
	[craft-pdf]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/pdf'
	[craft-print]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/print'
	[craft-proof]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/proof'
	[craft-rtf]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/rtf'
	[craft-sheet]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/sheet'
	[craft-ssip]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/ssip'
	[craft-tiff]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/tiff'
	[craft-ui]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/update'
	[craft-web-api]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/web-api'
	[craft-web-host]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/web-host'
	[craft-window]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/window'
	[craft-winprint-gdi]='https://github.com/storytold/winprint.rs;64e7afd4d1483512385012c340ecaaaf0f3beb7f;winprint.rs-%commit%/crates/gdi'
	[craft-wordmodel]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/wordmodel'
	[craft-xls]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/xls'
	[craft-xlsx]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/xlsx'
	[craft-xml]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/xml'
	[craft-zip]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/crates/zip'
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
	[krilla]='https://github.com/storytold/craft-libs;93dac78c93a7f1fd66e2022edeb089233b1dc45a;craft-libs-%commit%/vendor/krilla'
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
	[winprint]='https://github.com/storytold/winprint.rs;8ae097ef941b432b0e7671b1ec3a506800e65e57;winprint.rs-%commit%'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source word processor with Word file support, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/wordcraft https://github.com/storytold/wordcraft"
SRC_URI="
	https://github.com/storytold/wordcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
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
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CDLA-Permissive-2.0 IJG ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!app-office/wordcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/wordcraft usr/bin/wordcraft-cli"

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
	cargo_src_compile -p wordcraft -p wordcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{wordcraft,wordcraft-cli}

	local id=ai.storyteller.wordcraft
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
