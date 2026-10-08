# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (CRAFT_FONTS_REF in .github/workflows/release.yml)
CRAFT_FONTS_COMMIT="abb83316d96aa59c1cf64784289e378fe9fa5695"
RUST_MIN_VER="1.95.0"

CRATES="
"

inherit cargo desktop xdg

DESCRIPTION="Open-source layered image editor with PSD support, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/photocraft https://github.com/storytold/photocraft"
SRC_URI="
	https://github.com/storytold/photocraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	cjk? (
		https://github.com/storytold/craft-fonts/archive/${CRAFT_FONTS_COMMIT}.tar.gz
			-> craft-fonts-${CRAFT_FONTS_COMMIT:0:12}.tar.gz
	)
	https://github.com/switch87/snakebyte-overlay/releases/download/distfiles/${P}-crates.tar.xz
"

LICENSE="|| ( MIT Apache-2.0 ) cjk? ( OFL-1.1 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0 IJG
	ISC MIT MPL-2.0 UoI-NCSA OFL-1.1 UbuntuFontLicense-1.0 Unicode-3.0
	ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+cjk"

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/photocraft-bin
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
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/photocraft usr/bin/photocraft-cli"

src_configure() {
	# Embed the CJK fonts like the official releases do; without them the
	# app falls back to the system's CJK fonts.
	use cjk && export CRAFT_FONTS_DIR="${WORKDIR}/craft-fonts-${CRAFT_FONTS_COMMIT}" CRAFT_FONTS_REQUIRED=1
	cargo_src_configure
}

src_compile() {
	cargo_src_compile -p photocraft -p photocraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{photocraft,photocraft-cli}

	local app=ai.storyteller.photocraft
	domenu packaging/linux/${app}.desktop
	insinto /usr/share/mime/packages
	newins packaging/linux/${app}.mime.xml ${app}.xml
	sed -e "s/@VERSION@/${PV}/g" -e "s/@DATE@/$(date -u +%F)/g" \
		packaging/linux/${app}.metainfo.xml.in > "${T}"/${app}.metainfo.xml || die
	insinto /usr/share/metainfo
	doins "${T}"/${app}.metainfo.xml
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
