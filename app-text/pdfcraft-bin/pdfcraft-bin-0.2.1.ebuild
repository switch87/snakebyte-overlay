# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

# 0.2.1 was released under the interim name PrintCraft; the project is PdfCraft again.
MY_PN=printcraft

DESCRIPTION="Open-source PDF reader and editor, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/pdfcraft https://github.com/storytold/pdfcraft"
SRC_URI="https://github.com/storytold/pdfcraft/releases/download/v${PV}/${MY_PN}-${PV}-linux-x86_64.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}-linux-x86_64"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

# The binary links only against glibc; the rest is dlopen()ed at runtime
# (wgpu/winit): Vulkan or EGL, Wayland or X11, xkbcommon, D-Bus.
RDEPEND="
	!app-text/pdfcraft
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

QA_PREBUILT="usr/bin/${MY_PN} usr/bin/${MY_PN}-cli"

src_install() {
	dobin bin/${MY_PN} bin/${MY_PN}-cli

	insinto /usr/share
	doins -r share/applications share/icons share/metainfo share/mime

	dodoc share/doc/${MY_PN}/README.md
}
