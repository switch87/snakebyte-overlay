# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1 systemd

DESCRIPTION="Keep offline maps (Garmin .img) up to date in QMapShack and on Garmin devices"
HOMEPAGE="https://github.com/switch87/snakebyte-overlay"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	sys-apps/util-linux
	sys-fs/udisks:2
"

src_install() {
	python_newscript "${FILESDIR}"/map-update map-update
	systemd_douserunit "${FILESDIR}"/map-update.{service,timer}
	dodoc "${FILESDIR}"/README.md
	docompress -x /usr/share/doc/${PF}/README.md
}

pkg_postinst() {
	elog "The maps to keep up to date are listed in ~/.config/map-update.toml,"
	elog "created with an example (OpenFietsMap Benelux) on the first run."
	elog "Check for new versions without installing: map-update --check"
	elog "Weekly automatic updates (Sunday 20:00) for a user:"
	elog "  systemctl --user enable --now map-update.timer"
	elog "All options: map-update --help; documentation and map sources:"
	elog "  ${EROOT}/usr/share/doc/${PF}/README.md"
}
