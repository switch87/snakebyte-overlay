# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

WINE_V=11.18
DXVK_V=3.1.1
VKD3D_V=3.0.1
NVLIBS_V=1.0.2

DESCRIPTION="Prefix setup and launcher for Adobe Creative Cloud apps under Wine"
HOMEPAGE="https://github.com/le-birnes/AdobeWine"
SRC_URI="
	https://github.com/le-birnes/AdobeWine/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/doitsujin/dxvk/releases/download/v${DXVK_V}/dxvk-${DXVK_V}.tar.gz
	https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${VKD3D_V}/vkd3d-proton-${VKD3D_V}.tar.zst
	https://github.com/SveSop/nvidia-libs/releases/download/v${NVLIBS_V}/nvidia-libs-v${NVLIBS_V}.tar.xz
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
	# Upstream 0.2.2 ships the Gentoo install docs (PR 7) and the Selawik as
	# Segoe UI / D3D12 feature level / newest installed release fixes as
	# pull requests 3-5; only the two fixes below stay local.
	"${FILESDIR}"/${P}-selawik-substitutes-cleanup.patch
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
	doins -r "${WORKDIR}"/dxvk-${DXVK_V} "${WORKDIR}"/vkd3d-proton-${VKD3D_V} \
		"${WORKDIR}"/nvidia-libs-v${NVLIBS_V}

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
	elog "whose driver offers only 11_x, so Photoshop and Camera Raw use the GPU;"
	elog "on NVIDIA cards it installs the CUDA/NVENC/NVAPI bridges from nvidia-libs."
	if [[ -n ${REPLACING_VERSIONS} ]]; then
		elog
		elog "Upgrading: run 'adobewine setup' once more so existing prefixes get"
		elog "the new patches (After Effects render queue, Illustrator fonts, HiDPI)."
	fi
	elog "If the Adobe sign-in window stays blank: adobewine fix-signin"
}
