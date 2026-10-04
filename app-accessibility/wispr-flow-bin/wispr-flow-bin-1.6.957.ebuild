# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	aho-corasick@1.1.4
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-fs@2.2.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.14
	async-task@4.7.1
	async-trait@0.1.89
	atomic-waker@1.1.2
	atspi-common@0.6.0
	atspi-connection@0.6.0
	atspi-proxies@0.6.0
	atspi@0.22.0
	autocfg@1.5.1
	bitflags@2.12.1
	block-buffer@0.10.4
	blocking@1.6.2
	bytes@1.11.1
	cc@1.2.63
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	colorchoice@1.0.5
	concurrent-queue@2.5.0
	cpufeatures@0.2.17
	crossbeam-utils@0.8.21
	crypto-common@0.1.7
	digest@0.10.7
	downcast-rs@1.2.1
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	env_filter@1.0.1
	env_logger@0.11.10
	equivalent@1.0.2
	errno@0.3.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fastrand@2.4.1
	find-msvc-tools@0.1.9
	foldhash@0.1.5
	futures-core@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	generic-array@0.14.7
	gethostname@1.1.0
	getrandom@0.2.17
	getrandom@0.4.2
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	id-arena@2.3.0
	indexmap@2.14.0
	is_terminal_polyfill@1.70.2
	itoa@1.0.18
	jiff-static@0.2.28
	jiff@0.2.28
	leb128fmt@0.1.0
	libc@0.2.186
	linux-raw-sys@0.12.1
	log@0.4.31
	memchr@2.8.1
	memoffset@0.9.1
	mio@1.2.1
	nix@0.29.0
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	ordered-stream@0.2.0
	parking@2.2.1
	pin-project-lite@0.2.17
	piper@0.2.5
	pkg-config@0.3.33
	polling@3.11.0
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	quick-xml@0.30.0
	quick-xml@0.39.4
	quote@1.0.45
	r-efi@6.0.0
	rand@0.8.6
	rand_chacha@0.3.1
	rand_core@0.6.4
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	rustix@1.1.4
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_repr@0.1.20
	sha1@0.10.6
	shlex@2.0.1
	signal-hook-registry@1.4.8
	slab@0.4.12
	smallvec@1.15.1
	socket2@0.6.4
	static_assertions@1.1.0
	syn@2.0.117
	tempfile@3.27.0
	tokio@1.52.3
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.12+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing@0.1.44
	typenum@1.20.1
	uds_windows@1.2.1
	unicode-ident@1.0.24
	unicode-xid@0.2.6
	utf8parse@0.2.2
	version_check@0.9.5
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.3+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasmparser@0.244.0
	wayland-backend@0.3.15
	wayland-client@0.31.14
	wayland-protocols@0.32.12
	wayland-scanner@0.31.10
	wayland-sys@0.31.11
	windows-link@0.2.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@1.0.3
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	x11rb-protocol@0.13.2
	x11rb@0.13.2
	xdg-home@1.3.0
	zbus-lockstep-macros@0.4.4
	zbus-lockstep@0.4.4
	zbus@4.4.0
	zbus_macros@4.4.0
	zbus_names@3.0.0
	zbus_xml@4.0.0
	zerocopy-derive@0.8.50
	zerocopy@0.8.50
	zmij@1.0.21
	zvariant@4.2.0
	zvariant_derive@4.2.0
	zvariant_utils@2.1.0
"

inherit cargo udev unpacker xdg

# wispr-flow-linux wrapper release bundling Wispr Flow ${PV}
WRAPPER_PV="1.0.4"
HELPER_PV="0.1.2"
MY_DEB="wispr-flow_${PV}-${WRAPPER_PV}_amd64.deb"

DESCRIPTION="Wispr Flow voice dictation (unofficial Linux port)"
HOMEPAGE="
	https://wisprflow.ai/
	https://github.com/wispr-flow-linux/wispr-flow-linux
"
SRC_URI="
	https://github.com/wispr-flow-linux/wispr-flow-linux/releases/download/v${WRAPPER_PV}%2Bwispr${PV}/${MY_DEB}
	https://github.com/wispr-flow-linux/helper/archive/refs/tags/v${HELPER_PV}.tar.gz
		-> wispr-flow-linux-helper-${HELPER_PV}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/helper-${HELPER_PV}"

# Wispr Flow itself is proprietary; the Linux wrapper and helper are public
# domain (Unlicense); bundled Electron/Chromium: see LICENSES.chromium.html
LICENSE="all-rights-reserved Unlicense MIT BSD"
# Dependent crate licenses
LICENSE+=" Apache-2.0 MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	gui-apps/wl-clipboard
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	virtual/udev
"

PATCHES=(
	"${FILESDIR}"/wispr-flow-helper-0.1.2-no-modifier-restore.patch
)

QA_PREBUILT="usr/lib/wispr-flow/*"

src_unpack() {
	mkdir "${WORKDIR}"/deb || die
	cd "${WORKDIR}"/deb || die
	unpack_deb "${MY_DEB}"
	cd "${WORKDIR}" || die
	unpack wispr-flow-linux-helper-${HELPER_PV}.tar.gz
	cargo_src_unpack
}

src_install() {
	local deb="${WORKDIR}"/deb dir=/usr/lib/wispr-flow

	# Windows-only native modules shipped inside the upstream app
	rm "${deb}${dir}"/resources/app.asar.unpacked/.webpack/main/native_modules/lib/crypt32-*.node || die

	# our helper build replaces the prebuilt one
	cp "$(cargo_target_dir)"/wispr-flow-linux-helper \
		"${deb}${dir}"/resources/Release/wispr-flow-linux-helper || die

	# a dictation tool for office work, not a multimedia application
	sed -i -e 's/^Categories=.*/Categories=Office;Utility;Accessibility;/' \
		"${deb}"/usr/share/applications/wispr-flow.desktop || die

	udev_newrules "${deb}${dir}"/70-wispr-flow-uinput.rules 70-wispr-flow-uinput.rules
	rm "${deb}${dir}"/70-wispr-flow-uinput.rules || die

	cp -a "${deb}"/usr "${ED}"/ || die
	fowners root:root ${dir}/chrome-sandbox
	fperms 4755 ${dir}/chrome-sandbox
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload

	elog "The bundled udev rule gives the active session access to /dev/uinput"
	elog "(text injection) and /dev/input (push-to-talk). If that does not work,"
	elog "add your user to the input group: usermod -aG input <user>"
	elog "Run 'wispr-flow --doctor' to diagnose display, input and clipboard."
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
