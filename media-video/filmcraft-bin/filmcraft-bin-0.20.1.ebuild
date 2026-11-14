# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Open-source video editor, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/filmcraft https://github.com/storytold/filmcraft"
SRC_URI="https://github.com/storytold/filmcraft/releases/download/v${PV}/filmcraft-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/filmcraft-${PV}-linux-x86_64"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+pipewire"
RESTRICT="bindist mirror strip"

# The binary links only against glibc, gcc and ALSA; the rest is dlopen()ed at runtime
# (wgpu/winit): Vulkan or EGL, Wayland or X11, xkbcommon, D-Bus.
# Sound goes through ALSA's "default" device. On a PipeWire system that device only exists
# when PipeWire's ALSA plugin config is installed into /etc/alsa/conf.d (USE=pipewire-alsa);
# without it playback fails with "Unknown PCM default".
RDEPEND="
	!media-video/filmcraft
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

QA_PREBUILT="usr/bin/filmcraft usr/bin/filmcraft-cli"

src_install() {
	dobin bin/filmcraft bin/filmcraft-cli

	insinto /usr/share
	doins -r share/applications share/icons share/metainfo share/mime

	dodoc share/doc/filmcraft/README.md
}
