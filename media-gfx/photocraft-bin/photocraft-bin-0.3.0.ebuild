# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Open-source layered image editor with PSD support, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/photocraft https://github.com/storytold/photocraft"
SRC_URI="https://github.com/storytold/photocraft/releases/download/v${PV}/photocraft-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/photocraft-${PV}-linux-x86_64"

LICENSE="|| ( MIT Apache-2.0 ) OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

# The binary links only against glibc; the rest is dlopen()ed at runtime
# (wgpu/winit): Vulkan or EGL, Wayland or X11, xkbcommon, D-Bus.
RDEPEND="
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

QA_PREBUILT="usr/bin/photocraft usr/bin/photocraft-cli"

src_install() {
	dobin bin/photocraft bin/photocraft-cli

	insinto /usr/share
	doins -r share/applications share/icons share/metainfo share/mime

	dodoc share/doc/photocraft/README.md share/doc/photocraft/OFL-*.txt
}
