# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Prefer directly connected networks over Tailscale subnet routes"
HOMEPAGE="https://github.com/switch87/snakebyte-overlay"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	net-vpn/tailscale
	sys-apps/iproute2
"

src_install() {
	exeinto /usr/libexec
	doexe "${FILESDIR}"/tailscale-lan-route

	systemd_dounit "${FILESDIR}"/tailscale-lan-route.service
	newconfd "${FILESDIR}"/tailscale-lan-route.confd tailscale-lan-route

	insinto /usr/lib/systemd/networkd.conf.d
	doins "${FILESDIR}"/50-tailscale-lan-route.conf
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Enable the routing rule with:"
		elog "  systemctl enable --now tailscale-lan-route.service"
		elog "It also stops systemd-networkd from removing routing rules it did"
		elog "not create (/usr/lib/systemd/networkd.conf.d/)."
	fi
}
