# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Open-source vector illustration editor (SVG, PDF), written in Rust"
HOMEPAGE="https://getartcraft.com/apps/vectorcraft https://github.com/storytold/vectorcraft"
SRC_URI="https://github.com/storytold/vectorcraft/releases/download/v${PV}/vectorcraft-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/vectorcraft-${PV}-linux-x86_64"

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

QA_PREBUILT="usr/bin/vectorcraft usr/bin/vectorcraft-cli"

src_install() {
	dobin bin/vectorcraft bin/vectorcraft-cli

	insinto /usr/share
	doins -r share/applications share/icons share/metainfo share/mime

	dodoc share/doc/vectorcraft/README.md share/doc/vectorcraft/OFL-*.txt
}
