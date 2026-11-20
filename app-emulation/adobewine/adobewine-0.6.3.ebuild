# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature unpacker

WINE_V=11.20
DXVK_V=3.1.1
VKD3D_V=3.0.1
NVLIBS_V=1.0.2
MY_P="LinDobe-${PV}"

DESCRIPTION="Prefix setup and launcher for Adobe Creative Cloud apps under Wine (LinDobe)"
HOMEPAGE="https://github.com/le-birnes/LinDobe"
SRC_URI="
	https://github.com/le-birnes/LinDobe/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/doitsujin/dxvk/releases/download/v${DXVK_V}/dxvk-${DXVK_V}.tar.gz
	https://github.com/HansKristian-Work/vkd3d-proton/releases/download/v${VKD3D_V}/vkd3d-proton-${VKD3D_V}.tar.zst
	https://github.com/SveSop/nvidia-libs/releases/download/v${NVLIBS_V}/nvidia-libs-v${NVLIBS_V}.tar.xz
"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2.1+ ZLIB MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

RDEPEND="
	~app-emulation/wine-adobe-${WINE_V}[gecko,mono,vulkan,wow64]
	app-emulation/winetricks
	app-arch/7zip
	app-arch/cabextract
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
	# Portage's wine-adobe, DXVK/vkd3d-proton/nvidia-libs, wine-gecko and
	# wine-mono instead of downloads; drop the Selawik GDI substitutes that
	# adobewine-0.1.0-r1 wrote
	"${FILESDIR}"/${P}-gentoo.patch
)

src_prepare() {
	default
	sed -i -e "s/@WINE_V@/${WINE_V}/" bin/env.sh || die
}

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
	doins -r config hub scripts shims tools patches VERSION
	exeinto ${dir}/bin
	doexe bin/adobewine
	insinto ${dir}/bin
	doins bin/env.sh bin/app-catalog.sh
	fperms +x ${dir}/hub/adobewine-hub
	local f
	for f in scripts/*.sh scripts/*.py tools/*.sh tools/*.py; do
		fperms +x ${dir}/${f}
	done

	insinto ${dir}/lib
	doins d3d12.dll winclose.exe d3d12fl.exe

	insinto ${dir}/deps
	doins -r "${WORKDIR}"/dxvk-${DXVK_V} "${WORKDIR}"/vkd3d-proton-${VKD3D_V} \
		"${WORKDIR}"/nvidia-libs-v${NVLIBS_V}
	fperms +x ${dir}/deps/nvidia-libs-v${NVLIBS_V}/{setup_nvlibs,nvml_setup}.sh

	dosym -r ${dir}/bin/adobewine /usr/bin/adobewine
	dodoc README.md CHANGELOG.md docs/*.md
}

pkg_postinst() {
	elog "LinDobe (formerly AdobeWine) runs Adobe Creative Cloud apps with"
	elog "app-emulation/wine-adobe. Everything per user lives in"
	elog "\${XDG_DATA_HOME:-~/.local/share}/adobewine."
	elog
	elog "  adobewine setup [--windows-fonts DIR]   create the prefix (once)"
	elog "  adobewine run <installer.exe>          e.g. the Creative Cloud installer"
	elog "  adobewine launchers                    add installed apps to the menu"
	elog "  adobewine photoshop | cc | off         start Photoshop / Creative Cloud, stop all"
	elog
	elog "Adobe's UI needs Segoe UI. Pass the Fonts folder of a Windows installation"
	elog "you own with --windows-fonts; without it, setup makes Segoe UI from Selawik."
	elog "The patched DXVK/vkd3d-proton/nvcuda builds of upstream's build-gpu-deps.sh"
	elog "(After Effects viewers, Premiere on Intel, Lightroom videos) are not built"
	elog "here; the stock DXVK ${DXVK_V} and vkd3d-proton ${VKD3D_V} are used."
	if [[ -n ${REPLACING_VERSIONS} ]]; then
		elog
		elog "Upgrading: run 'adobewine setup' once more so existing prefixes get"
		elog "the new Wine runtime and settings."
	fi
	optfeature "the LinDobe hub window (/opt/adobewine/hub/adobewine-hub)" \
		"gui-libs/libadwaita dev-python/pygobject"
}
