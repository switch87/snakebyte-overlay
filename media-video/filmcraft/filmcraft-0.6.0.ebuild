# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

inherit cargo desktop xdg

DESCRIPTION="Open-source video editor, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/filmcraft https://github.com/storytold/filmcraft"
SRC_URI="
	https://github.com/storytold/filmcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
"

LICENSE="|| ( MIT Apache-2.0 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD Boost-1.0
	CDLA-Permissive-2.0 ISC MIT MPL-2.0 OFL-1.1 UbuntuFontLicense-1.0
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+pipewire whisper"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
# Sound goes through ALSA's "default" device; on a PipeWire system that needs
# PipeWire's ALSA config in /etc/alsa/conf.d (USE=pipewire-alsa).
RDEPEND="
	!media-video/filmcraft-bin
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

QA_FLAGS_IGNORED="usr/bin/filmcraft usr/bin/filmcraft-cli"

src_configure() {
	local myfeatures=()
	# Speech-to-text (Text panel > Transcribe) with Whisper on the CPU (candle),
	# plus downloading the speech models over HTTPS; off upstream.
	use whisper && myfeatures+=( filmcraft/whisper )
	cargo_src_configure
}

src_compile() {
	cargo_src_compile -p filmcraft -p filmcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{filmcraft,filmcraft-cli}

	local id=ai.storyteller.filmcraft
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
