# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

CRATES="
"

declare -A GIT_CRATES=(
	[craft-atomic]='https://github.com/storytold/craft-libs;e9546e191dd62f2bc1d61eca45dbdc2f1b3c1d8e;craft-libs-%commit%/crates/atomic'
	[craft-cms]='https://github.com/storytold/craft-libs;e9546e191dd62f2bc1d61eca45dbdc2f1b3c1d8e;craft-libs-%commit%/crates/cms'
	[craft-docpath]='https://github.com/storytold/craft-libs;82a24b006eefa036b43c09a67fb9a3fbd17ffe63;craft-libs-%commit%/crates/docpath'
	[craft-pdf]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/crates/pdf'
	[craft-print]='https://github.com/storytold/craft-libs;d991bf6792f8ade99c51358bf3c1d902c8cd96b5;craft-libs-%commit%/crates/print'
	[craft-ui]='https://github.com/storytold/craft-libs;5c874d51eeb3de70e735c8ce87a59a7dedd47675;craft-libs-%commit%/crates/ui'
	[hayro-interpret]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/vendor/hayro-interpret'
	[hayro-jbig2]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/vendor/hayro-jbig2'
	[hayro-syntax]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/vendor/hayro-syntax'
	[hayro]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/vendor/hayro'
	[indd]='https://github.com/storytold/indd-utils;7f3060e5bce78d21ea70e0d5eacb96edce15dfbe;indd-utils-%commit%'
	[krilla]='https://github.com/storytold/craft-libs;89dcbb3060377a26c99a6d80caa16084366704c4;craft-libs-%commit%/vendor/krilla'
	[winit]='https://github.com/storytold/winit;3d51077fd1a966f84df9ef287839dc84fd5b4ca7;winit-%commit%'
)

inherit cargo desktop xdg

DESCRIPTION="Open-source page layout and print design application, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/designcraft https://github.com/storytold/designcraft"
SRC_URI="
	https://github.com/storytold/designcraft/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
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

# winit/wgpu dlopen() the windowing and GPU libraries at runtime.
RDEPEND="
	!media-gfx/designcraft-bin
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
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/designcraft usr/bin/designcraft-cli"

src_prepare() {
	default
	# Cargo.toml's [patch.crates-io] points crates at git; the eclass only patches the
	# git URLs, so send those crates to the unpacked GIT_CRATES too (the cargo config's
	# [patch] wins over Cargo.toml's).
	local crate uri commit dir
	{
		echo "[patch.crates-io]"
		for crate in $(sed -n '/^\[patch\.crates-io\]/,/^\[/s/^\([A-Za-z0-9_-]\+\) *= *{.*git *=.*/\1/p' Cargo.toml); do
			IFS=';' read -r uri commit dir _ <<< "${GIT_CRATES[${crate}]}"
			[[ -n ${commit} ]] || die "${crate} is patched from git but not in GIT_CRATES"
			dir=${dir:-${crate}-%commit%}
			echo "${crate} = { path = \"${WORKDIR}/${dir//%commit%/${commit}}\" }"
		done
	} >> "${ECARGO_HOME}"/config.toml || die
}

src_compile() {
	cargo_src_compile -p designcraft -p designcraft-cli
}

src_install() {
	dobin "$(cargo_target_dir)"/{designcraft,designcraft-cli}

	local id=ai.storyteller.designcraft
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
