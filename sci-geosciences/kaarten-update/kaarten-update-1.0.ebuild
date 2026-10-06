# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1 systemd

DESCRIPTION="Keep Garmin .img maps up to date in QMapShack and on Garmin devices"
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
	python_newscript "${FILESDIR}"/kaarten-update kaarten-update
	systemd_douserunit "${FILESDIR}"/kaarten-update.{service,timer}
}

pkg_postinst() {
	elog "The maps to keep up to date are listed in ~/.config/kaarten-update.toml,"
	elog "created with an example (OpenFietsMap Benelux) on the first run."
	elog "Check for new versions without installing: kaarten-update --check"
	elog "Weekly automatic updates (Sunday 20:00) for a user:"
	elog "  systemctl --user enable --now kaarten-update.timer"
}
