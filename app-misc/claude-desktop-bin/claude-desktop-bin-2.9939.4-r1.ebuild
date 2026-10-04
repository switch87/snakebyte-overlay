# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Desktop application for Claude.ai (official Linux build)"
HOMEPAGE="https://claude.com/download https://code.claude.com/docs/en/desktop-linux"
SRC_URI="https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${PV}_amd64.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+cowork"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	sys-apps/util-linux
	sys-apps/xdg-desktop-portal
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libXtst
	x11-misc/xdg-utils
	cowork? (
		app-emulation/qemu[qemu_softmmu_targets_x86_64]
		app-emulation/virtiofsd
		sys-firmware/edk2-bin
	)
"

QA_PREBUILT="usr/lib/claude-desktop/*"

src_install() {
	# Debian/GNOME-only bits: lintian overrides and the GNOME Shell search
	# provider (registered by the deb's postinst, not needed on Plasma)
	rm -r usr/share/lintian usr/lib/claude-desktop/resources/gnome-search-provider || die

	mv usr/share/doc/claude-desktop usr/share/doc/${PF} || die

	cp -a usr "${ED}"/ || die
	fowners root:root /usr/lib/claude-desktop/chrome-sandbox
	fperms 4755 /usr/lib/claude-desktop/chrome-sandbox

	if use cowork; then
		# The Cowork VM only looks for UEFI firmware at Debian's paths
		# (/usr/share/OVMF/OVMF_CODE{_4M,}.fd, VARS next to it); without
		# them it reports the VM as unsupported.
		dosym -r /usr/share/edk2/OvmfX64/OVMF_CODE.fd /usr/share/OVMF/OVMF_CODE.fd
		dosym -r /usr/share/edk2/OvmfX64/OVMF_VARS.fd /usr/share/OVMF/OVMF_VARS.fd
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	if ! use cowork; then
		elog "Without USE=cowork the Cowork tab reports that QEMU is missing."
	fi
	elog "Claude Desktop does not update itself here; new versions arrive as"
	elog "ebuild bumps (files/claude-desktop-bump reads Anthropic's apt index)."
}
