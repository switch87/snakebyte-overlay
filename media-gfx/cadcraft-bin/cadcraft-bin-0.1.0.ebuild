# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Open-source 2D CAD drafting application, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/cadcraft https://github.com/storytold/cadcraft"
SRC_URI="https://github.com/storytold/cadcraft/releases/download/v${PV}/cadcraft-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/cadcraft-${PV}-linux-x86_64"

LICENSE="|| ( MIT Apache-2.0 )"
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

QA_PREBUILT="usr/bin/cadcraft usr/bin/cadcraft-cli"

src_install() {
	dobin bin/cadcraft bin/cadcraft-cli

	insinto /usr/share
	doins -r share/applications share/metainfo share/mime

	dodoc share/doc/cadcraft/README.md
}
