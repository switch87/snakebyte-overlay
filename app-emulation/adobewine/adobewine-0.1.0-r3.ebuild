# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

WINE_V=11.18
DXVK_V=3.1.1
VKD3D_V=3.0.1

DESCRIPTION="Prefix setup and launcher for Adobe Creative Cloud apps under Wine"
HOMEPAGE="https://github.com/le-birnes/AdobeWine"
SRC_URI="
	https://github.com/le-birnes/AdobeWine/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/doitsujin/dxvk/releases/download/v${DXVK_V}/dxvk-${DXVK_V}.tar.gz
	https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${VKD3D_V}/vkd3d-proton-${VKD3D_V}.tar.zst
"
S="${WORKDIR}/AdobeWine-${PV}"

LICENSE="LGPL-2.1+ ZLIB MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	~app-emulation/wine-adobe-${WINE_V}[gecko,mono,vulkan,wow64]
	app-emulation/winetricks
	app-arch/7zip
	media-fonts/selawik
	dev-python/pillow
	media-libs/fontconfig
	media-libs/vulkan-loader
	net-misc/curl
"
BDEPEND="
	$(unpacker_src_uri_depends)
	dev-util/mingw64-toolchain[abi_x86_64]
"

QA_PREBUILT="opt/adobewine/deps/* opt/adobewine/lib/*"

PATCHES=(
	"${FILESDIR}"/${P}-gentoo-paths.patch
	# Upstream pull requests (code only), drop each one once merged:
	# https://github.com/le-birnes/AdobeWine/pull/3 - Segoe UI from Selawik (Photoshop menu bar hang)
	"${FILESDIR}"/${P}-pr3-segoe-ui-from-selawik.patch
	# https://github.com/le-birnes/AdobeWine/pull/4 - D3D12 feature level 12_0/12_1 (Photoshop and Camera Raw see no GPU)
	"${FILESDIR}"/${P}-pr4-d3d12-feature-level.patch
	# https://github.com/le-birnes/AdobeWine/pull/5 - newest installed release, menu icons
	"${FILESDIR}"/${P}-pr5-newest-release.patch
	# Gentoo only: undo the Segoe UI -> Selawik GDI substitutes that -r1 set up
	"${FILESDIR}"/${P}-r1-selawik-substitutes.patch
)

src_compile() {
	local -x PATH="${BROOT}/usr/lib/mingw64-toolchain/bin:${PATH}"
	x86_64-w64-mingw32-gcc -O2 -shared -o d3d12.dll shims/d3d12/d3d12shim.c \
		shims/d3d12/d3d12.def -Wl,--enable-stdcall-fixup || die
	x86_64-w64-mingw32-gcc -O2 -o winclose.exe tools/winclose/winclose.c || die
	x86_64-w64-mingw32-gcc -O2 -o d3d12fl.exe tools/d3d12fl/d3d12fl.c || die
}

src_install() {
	local dir=/opt/adobewine

	insinto ${dir}
	doins -r scripts shims tools patches VERSION
	exeinto ${dir}/bin
	doexe bin/adobewine
	insinto ${dir}/bin
	doins bin/env.sh
	fperms +x ${dir}/scripts/{build-wine,fetch-deps,install-launchers,make-release,register-fonts,report,setup-prefix}.sh

	insinto ${dir}/lib
	doins d3d12.dll winclose.exe d3d12fl.exe

	insinto ${dir}/deps
	doins -r "${WORKDIR}"/dxvk-${DXVK_V} "${WORKDIR}"/vkd3d-proton-${VKD3D_V}

	dosym -r ${dir}/bin/adobewine /usr/bin/adobewine
	dodoc README.md CHANGELOG.md docs/*.md
}

pkg_postinst() {
	elog "AdobeWine runs Adobe Creative Cloud apps with app-emulation/wine-adobe."
	elog "Everything per user lives in \${XDG_DATA_HOME:-~/.local/share}/adobewine."
	elog
	elog "  adobewine setup [--windows-fonts DIR]   create the prefix (once)"
	elog "  adobewine run <installer.exe>          e.g. the Creative Cloud installer"
	elog "  adobewine launchers                    add installed apps to the menu"
	elog "  adobewine photoshop | cc | off         start Photoshop / Creative Cloud, stop all"
	elog
	elog "Adobe's UI needs Segoe UI. Pass the Fonts folder of a Windows installation"
	elog "you own with --windows-fonts; without it, setup makes Segoe UI from Selawik."
	elog "Setup also checks the Direct3D 12 feature level and reports 12_0/12_1 on GPUs"
	elog "whose driver offers only 11_x, so Photoshop and Camera Raw use the GPU."
	if [[ -n ${REPLACING_VERSIONS} ]]; then
		elog
		elog "Upgrading: run 'adobewine setup' once more so existing prefixes get"
		elog "these fixes."
	fi
	elog "If the Adobe sign-in window stays blank: adobewine fix-signin"
}
