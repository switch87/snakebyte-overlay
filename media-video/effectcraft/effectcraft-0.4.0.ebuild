# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[filmcraft-aac]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/aac'
	[filmcraft-ac3]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/ac3'
	[filmcraft-av1]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/av1'
	[filmcraft-bitstream]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/bitstream'
	[filmcraft-cfb]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/cfb'
	[filmcraft-codecs]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/codecs'
	[filmcraft-color]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/color'
	[filmcraft-dnx]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/dnx'
	[filmcraft-frame]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/frame'
	[filmcraft-geom]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/geom'
	[filmcraft-h264]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/h264'
	[filmcraft-h264enc]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/h264enc'
	[filmcraft-hevc]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/hevc'
	[filmcraft-interchange]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/interchange'
	[filmcraft-isobmff]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/isobmff'
	[filmcraft-matroska]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/matroska'
	[filmcraft-media]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/media'
	[filmcraft-mpeg2v]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/mpeg2v'
	[filmcraft-mpegts]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/mpegts'
	[filmcraft-mxf]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/mxf'
	[filmcraft-ogg]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/ogg'
	[filmcraft-opus]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/opus'
	[filmcraft-project]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/project'
	[filmcraft-prores]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/prores'
	[filmcraft-time]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/time'
	[filmcraft-vp9]='https://github.com/storytold/filmcraft;2c5ba7a72619935f0481f99d59409e0d1844b234;filmcraft-%commit%/crates/vp9'
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
	Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
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
