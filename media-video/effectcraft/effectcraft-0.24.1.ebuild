# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/docpath'
	[craft-ecproj-format]='https://github.com/storytold/craft-libs;ca1b5e2edb8568335c6c14f390307bd5beae8238;craft-libs-%commit%/crates/ecproj-format'
	[craft-fonts-build]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/fonts-build'
	[craft-i18n]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/i18n'
	[craft-media]='https://github.com/storytold/craft-libs;f0ad6c1e1d297908915f4be315b0fcfc9be7b5d4;craft-libs-%commit%/crates/media'
	[craft-pdf]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/pdf'
	[craft-quit]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/quit'
	[craft-ui]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/crates/ui'
	[craft-update]='https://github.com/storytold/craft-libs;6e03f65bf45181db77ba6229716e6624db9eb25b;craft-libs-%commit%/crates/update'
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
	[filmcraft-aac]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/aac'
	[filmcraft-ac3]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/ac3'
	[filmcraft-apv]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/apv'
	[filmcraft-av1]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/av1'
	[filmcraft-avi]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/avi'
	[filmcraft-bitstream]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/bitstream'
	[filmcraft-cfb]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/cfb'
	[filmcraft-codecs]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/codecs'
	[filmcraft-color]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/color'
	[filmcraft-dng]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/dng'
	[filmcraft-dnx]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/dnx'
	[filmcraft-frame]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/frame'
	[filmcraft-geom]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/geom'
	[filmcraft-h264]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/h264'
	[filmcraft-h264enc]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/h264enc'
	[filmcraft-hevc]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/hevc'
	[filmcraft-interchange]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/interchange'
	[filmcraft-isobmff]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/isobmff'
	[filmcraft-matroska]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/matroska'
	[filmcraft-media]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/media'
	[filmcraft-mpa]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/mpa'
	[filmcraft-mpeg2v]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/mpeg2v'
	[filmcraft-mpegts]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/mpegts'
	[filmcraft-mxf]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/mxf'
	[filmcraft-ogg]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/ogg'
	[filmcraft-opus]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/opus'
	[filmcraft-project]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/project'
	[filmcraft-prores]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/prores'
	[filmcraft-time]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/time'
	[filmcraft-vp8]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/vp8'
	[filmcraft-vp9]='https://github.com/storytold/filmcraft;d5ead4ba1ee2f1cd13cb86a4239aee2730a3d9f5;filmcraft-%commit%/crates/vp9'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-syntax]='https://github.com/storytold/craft-libs;e11f9d9aebea5f6b8e74643c1ea1ed172ba5f545;craft-libs-%commit%/vendor/hayro-syntax'
	[winit]='https://github.com/storytold/winit;a517b3846ee8457d84ee4975110bfda6797c44dc;winit-%commit%'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source motion graphics and visual effects compositor, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/effectcraft https://github.com/storytold/effectcraft"
SRC_URI="
	https://github.com/storytold/effectcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+pipewire"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
# Sound goes through ALSA's "default" device; on a PipeWire system that needs
# PipeWire's ALSA config in /etc/alsa/conf.d (USE=pipewire-alsa).
RDEPEND="
	!media-video/effectcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/effectcraft usr/bin/effectcraft-cli"

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
	cargo_src_compile -p effectcraft -p effectcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{effectcraft,effectcraft-cli}

	local id=ai.storyteller.effectcraft
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
