# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Open-source word processor with Word file support, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/wordcraft https://github.com/storytold/wordcraft"
SRC_URI="https://github.com/storytold/wordcraft/releases/download/v${PV}/wordcraft-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/wordcraft-${PV}-linux-x86_64"

LICENSE="|| ( MIT Apache-2.0 ) OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

# The binary links only against glibc; the rest is dlopen()ed at runtime
# (wgpu/winit): Vulkan or EGL, Wayland or X11, xkbcommon, D-Bus.
RDEPEND="
	!app-office/wordcraft
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

QA_PREBUILT="usr/bin/wordcraft usr/bin/wordcraft-cli"

src_install() {
	dobin bin/wordcraft bin/wordcraft-cli

	insinto /usr/share
	doins -r share/applications share/icons share/metainfo share/mime

	dodoc share/doc/wordcraft/README.md share/doc/wordcraft/OFL-*.txt
}
