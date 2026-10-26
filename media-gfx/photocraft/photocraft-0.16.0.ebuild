# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# craft-fonts commit the upstream release embeds (CRAFT_FONTS_REF in .github/workflows/release.yml)
CRAFT_FONTS_COMMIT="abb83316d96aa59c1cf64784289e378fe9fa5695"
RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-docpath]='https://github.com/storytold/craft-libs;82a24b006eefa036b43c09a67fb9a3fbd17ffe63;craft-libs-%commit%/crates/docpath'
	[craft-jpeg]='https://github.com/storytold/craft-libs;6e7f28518dd1cb57e1624bdc269c3c14316b13ae;craft-libs-%commit%/crates/jpeg'
	[craft-print]='https://github.com/storytold/craft-libs;3d37da389a3618ab9b76109da11416e9ca4ea719;craft-libs-%commit%/crates/print'
	[craft-ui]='https://github.com/storytold/craft-libs;5c874d51eeb3de70e735c8ce87a59a7dedd47675;craft-libs-%commit%/crates/ui'
	[craft-winprint-gdi]='https://github.com/storytold/winprint.rs;417ac3c4d14d3da5485a99c7d5ce8f05664ec312;winprint.rs-%commit%/crates/gdi'
	[winprint]='https://github.com/storytold/winprint.rs;5f80b9baf6b58937c401656634e42d33f00ddf49;winprint.rs-%commit%'
)

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
	${CARGO_CRATE_URIS}
"

LICENSE="|| ( MIT Apache-2.0 ) cjk? ( OFL-1.1 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CDLA-Permissive-2.0 IJG ISC MIT MPL-2.0 UoI-NCSA OFL-1.1
	UbuntuFontLicense-1.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="avif +cjk +heif"

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
	local myfeatures=()
	# AVIF export (ravif/rav1e, pure Rust); off upstream
	use avif && myfeatures+=( photocraft-codecs/avif )
	# HEIC/HEIF decoding (pure Rust); official builds enable it
	use heif && myfeatures+=( photocraft-codecs/heif )
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
