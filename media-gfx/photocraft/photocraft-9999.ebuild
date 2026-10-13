# Copyright 2026 Gert Pellin
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.95.0"

inherit cargo desktop git-r3 xdg

DESCRIPTION="Open-source layered image editor with PSD support, written in Rust"
HOMEPAGE="https://getartcraft.com/apps/photocraft https://github.com/storytold/photocraft"
EGIT_REPO_URI="https://github.com/storytold/photocraft.git"
EGIT_BRANCH="main"

LICENSE="|| ( MIT Apache-2.0 ) cjk? ( OFL-1.1 )"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0 IJG
	ISC MIT MPL-2.0 UoI-NCSA OFL-1.1 UbuntuFontLicense-1.0 Unicode-3.0
	ZLIB
"
SLOT="0"
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

CRAFT_FONTS_REPO="https://github.com/storytold/craft-fonts.git"

src_unpack() {
	git-r3_src_unpack
	# main can pin git dependencies to commits that only live on a pull-request
	# branch (craft-print in craft-libs); libgit2 cannot fetch those by hash, the
	# git CLI can.
	export CARGO_NET_GIT_FETCH_WITH_CLI=true
	cargo_live_src_unpack

	if use cjk; then
		# Embed the same craft-fonts commit the upstream release workflow pins.
		local ref
		ref=$(sed -n 's/.*craft-fonts-ref:[[:space:]]*\([0-9a-f]\{40\}\).*/\1/p' \
			"${S}"/.github/workflows/release.yml | head -n 1)
		[[ -n ${ref} ]] || die "craft-fonts-ref not found in release.yml"
		git-r3_fetch "${CRAFT_FONTS_REPO}" "${ref}" craft-fonts
		git-r3_checkout "${CRAFT_FONTS_REPO}" "${WORKDIR}/craft-fonts" craft-fonts
	fi
}

src_configure() {
	# Embed the CJK fonts like the official releases do; without them the
	# app falls back to the system's CJK fonts.
	use cjk && export CRAFT_FONTS_DIR="${WORKDIR}/craft-fonts" CRAFT_FONTS_REQUIRED=1
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

	local app=ai.storyteller.photocraft ver
	ver=$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -n 1)
	domenu packaging/linux/${app}.desktop
	insinto /usr/share/mime/packages
	newins packaging/linux/${app}.mime.xml ${app}.xml
	sed -e "s/@VERSION@/${ver}+git${EGIT_VERSION:0:8}/g" -e "s/@DATE@/$(date -u +%F)/g" \
		packaging/linux/${app}.metainfo.xml.in > "${T}"/${app}.metainfo.xml || die
	insinto /usr/share/metainfo
	doins "${T}"/${app}.metainfo.xml
	insinto /usr/share/icons
	doins -r assets/app-icon/hicolor

	dodoc README.md
	if use cjk; then
		local lic
		for lic in "${WORKDIR}"/craft-fonts/fonts/*/OFL.txt; do
			newdoc "${lic}" "OFL-$(basename "$(dirname "${lic}")").txt"
		done
	fi
}
