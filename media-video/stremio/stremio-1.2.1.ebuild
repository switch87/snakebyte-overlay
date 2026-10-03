# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	aho-corasick@1.1.4
	aligned-vec@0.6.4
	aligned@0.4.3
	android_system_properties@0.1.5
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	arbitrary@1.4.2
	arg_enum_proc_macro@0.3.4
	arrayvec@0.7.7
	as-slice@0.2.1
	ashpd@0.13.13
	async-broadcast@0.7.2
	async-channel@2.5.0
	async-executor@1.14.0
	async-io@2.6.0
	async-lock@3.4.2
	async-process@2.5.0
	async-recursion@1.1.1
	async-signal@0.2.14
	async-task@4.7.1
	async-trait@0.1.89
	atomic-waker@1.1.2
	autocfg@1.5.1
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.9
	base64@0.23.0
	bit_field@0.10.3
	bitflags@1.3.2
	bitflags@2.13.0
	bitstream-io@4.10.0
	block@0.1.6
	blocking@1.6.2
	built@0.8.1
	bumpalo@3.20.3
	bytemuck@1.25.0
	byteorder-lite@0.1.0
	bytes@1.12.0
	cairo-rs@0.22.0
	cairo-sys-rs@0.22.0
	cc@1.2.65
	cfg-expr@0.20.8
	cfg-if@1.0.4
	chrono@0.4.45
	clap@4.6.5
	clap_builder@4.6.5
	clap_derive@4.6.4
	clap_lex@1.1.0
	color_quant@1.1.0
	colorchoice@1.0.5
	concurrent-queue@2.5.0
	core-foundation-sys@0.8.7
	crc32fast@1.5.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	dirs-sys@0.5.0
	dirs@6.0.0
	discord-rich-presence@1.1.0
	displaydoc@0.2.6
	dlib@0.5.3
	downcast-rs@1.2.1
	either@1.16.0
	endi@1.1.1
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	epoxy@0.1.0
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	errno@0.3.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	exr@1.74.0
	fastrand@2.4.1
	fax@0.2.7
	fdeflate@0.3.7
	field-offset@0.3.6
	find-msvc-tools@0.1.9
	flate2@1.1.9
	flume@0.12.0
	form_urlencoded@1.2.2
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	gdk-pixbuf-sys@0.22.0
	gdk-pixbuf@0.22.0
	gdk4-sys@0.11.2
	gdk4-wayland-sys@0.11.0
	gdk4-wayland@0.11.4
	gdk4-x11-sys@0.11.0
	gdk4-x11@0.11.0
	gdk4@0.11.2
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	gettext-rs@0.7.7
	gettext-sys@0.26.0
	gif@0.14.2
	gio-sys@0.22.0
	gio@0.22.6
	gl_generator@0.9.0
	glib-macros@0.22.6
	glib-sys@0.22.6
	glib@0.22.7
	gobject-sys@0.22.6
	graphene-rs@0.22.0
	graphene-sys@0.22.0
	gsk4-sys@0.11.1
	gsk4@0.11.1
	gtk4-macros@0.11.0
	gtk4-sys@0.11.3
	gtk4@0.11.4
	half@2.7.1
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	idna@1.1.0
	idna_adapter@1.2.2
	image-webp@0.2.4
	image@0.25.10
	imgref@1.12.2
	indexmap@2.14.0
	interpolate_name@0.2.4
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	javascriptcore6-sys@0.6.0
	javascriptcore6@0.6.0
	jobserver@0.1.34
	js-sys@0.3.103
	khronos_api@2.2.0
	ksni@0.3.6
	lazy_static@1.5.0
	lebe@0.5.3
	libadwaita-sys@0.9.2
	libadwaita@0.9.2
	libc@0.2.189
	libfuzzer-sys@0.4.13
	libloading@0.8.9
	libloading@0.9.0
	libredox@0.1.17
	linux-raw-sys@0.12.1
	litemap@0.8.2
	locale_config@0.3.0
	lock_api@0.4.14
	log@0.4.33
	loop9@0.1.5
	malloc_buf@0.0.6
	maybe-rayon@0.1.1
	memchr@2.8.2
	memoffset@0.9.1
	miniz_oxide@0.8.9
	mio@1.2.1
	moxcms@0.8.1
	mpris-server@0.10.0
	new_debug_unreachable@1.0.6
	no_std_io2@0.9.4
	nom@8.0.0
	noop_proc_macro@0.3.0
	nu-ansi-term@0.50.3
	num-bigint@0.4.6
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	objc-foundation@0.1.1
	objc@0.2.7
	objc_id@0.1.1
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	option-ext@0.2.0
	ordered-stream@0.2.0
	pango-sys@0.22.0
	pango@0.22.6
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pastey@0.2.3
	percent-encoding@2.3.2
	pin-project-lite@0.2.17
	piper@0.2.5
	pkg-config@0.3.33
	png@0.18.1
	polling@3.11.0
	potential_utf@0.1.5
	ppv-lite86@0.2.21
	proc-macro-crate@3.5.0
	proc-macro2@1.0.106
	profiling-procmacros@1.0.18
	profiling@1.0.18
	pxfm@0.1.29
	qoi@0.4.1
	quick-error@2.0.1
	quick-xml@0.39.4
	quote@1.0.46
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.9.4
	rand_chacha@0.9.0
	rand_core@0.9.5
	rav1e@0.8.1
	ravif@0.13.0
	rayon-core@1.13.0
	rayon@1.12.0
	redox_syscall@0.5.18
	redox_users@0.5.2
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	rgb@0.8.53
	rustc_version@0.4.1
	rustix@1.1.4
	rustversion@1.0.22
	scoped-tls@1.0.1
	scopeguard@1.2.0
	semver@1.0.28
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_repr@0.1.20
	serde_spanned@1.1.1
	sharded-slab@0.1.7
	shared_library@0.1.9
	shlex@2.0.1
	signal-hook-registry@1.4.8
	simd-adler32@0.3.9
	simd_helpers@0.1.0
	slab@0.4.12
	smallvec@1.15.2
	socket2@0.6.4
	soup3-sys@0.9.0
	soup3@0.9.0
	spin@0.9.8
	stable_deref_trait@1.2.1
	strsim@0.11.1
	syn@2.0.118
	syn@3.0.3
	synstructure@0.13.2
	system-deps@7.0.8
	target-lexicon@0.13.5
	temp-dir@0.1.16
	tempfile@3.27.0
	thiserror-impl@2.0.18
	thiserror@2.0.18
	thread_local@1.1.9
	tiff@0.11.3
	tinystr@0.8.3
	tokio-macros@2.7.0
	tokio@1.53.1
	toml@1.1.2+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.12+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.1+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	trait-variant@0.1.2
	uds_windows@1.2.1
	unicode-ident@1.0.24
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@0.8.2
	uuid@1.23.4
	v_frame@0.3.9
	valuable@0.1.1
	version-compare@0.2.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-macro-support@0.2.126
	wasm-bindgen-macro@0.2.126
	wasm-bindgen-shared@0.2.126
	wasm-bindgen@0.2.126
	wayland-backend@0.3.15
	wayland-client@0.31.14
	wayland-protocols@0.32.12
	wayland-scanner@0.31.10
	wayland-sys@0.31.11
	webkit6-sys@0.6.0
	webkit6@0.6.1
	weezl@0.1.12
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.61.2
	winnow@1.0.3
	wit-bindgen@0.57.1
	writeable@0.6.3
	x11-dl@2.21.0
	xml-rs@0.7.0
	y4m@0.8.0
	yoke-derive@0.8.2
	yoke@0.8.3
	zbus@5.16.0
	zbus_macros@5.16.0
	zbus_names@4.3.2
	zerocopy-derive@0.8.52
	zerocopy@0.8.52
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
	zune-core@0.5.1
	zune-inflate@0.2.54
	zune-jpeg@0.5.15
	zvariant@5.12.0
	zvariant_derive@5.12.0
	zvariant_utils@3.4.0
"

declare -A GIT_CRATES=(
	[libmpv2-sys]='https://github.com/Stremio/libmpv2-rs;9e19e7436a933c5eb1ca1b2b16bb9fbe86479576;libmpv2-rs-%commit%/libmpv-sys'
	[libmpv2]='https://github.com/Stremio/libmpv2-rs;9e19e7436a933c5eb1ca1b2b16bb9fbe86479576;libmpv2-rs-%commit%'
)

RUST_MIN_VER="1.88.0"

inherit cargo desktop gnome2-utils xdg

MY_P="stremio-linux-shell-${PV}"

DESCRIPTION="Stremio - The freedom to stream (GTK4/WebKitGTK shell)"
HOMEPAGE="
	https://www.stremio.com
	https://github.com/Stremio/stremio-linux-shell
"
SRC_URI="
	https://github.com/Stremio/stremio-linux-shell/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD ISC LGPL-2.1
	MIT MPL-2.0 UoI-NCSA Unicode-3.0 Unlicense
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-libs/glib-2.84:2
	>=gui-libs/gtk-4.22:4[wayland]
	>=gui-libs/libadwaita-1.9:1
	>=net-libs/webkit-gtk-2.52:6
	media-video/mpv:=[libmpv]
	media-libs/libepoxy
	sys-apps/dbus
	sys-devel/gettext
"
RDEPEND="
	${DEPEND}
	net-libs/nodejs
"
BDEPEND="
	dev-libs/glib:2
	sys-devel/gettext
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="usr/libexec/stremio/stremio"

src_prepare() {
	default

	# Upstream only knows the in-tree (dev) and flatpak locale dirs.
	sed -i \
		-e 's|concat!(env!("CARGO_MANIFEST_DIR"), "/po")|"/usr/share/locale"|' \
		src/config.rs || die
	grep -q '"/usr/share/locale"' src/config.rs || die "locale path sed failed"

	# build.rs compiles the GSettings schema into the user's data dir;
	# we install and compile it system-wide instead.
	sed -i -e '/setup_schemas(/d' build.rs || die
}

src_install() {
	exeinto /usr/libexec/stremio
	newexe "$(cargo_target_dir)"/stremio-linux-shell stremio
	insinto /usr/libexec/stremio
	doins data/server.js

	newbin - stremio <<-EOF
		#!/bin/sh
		# Use the GSK OpenGL renderer on NVIDIA cards (as upstream does)
		[ -e /dev/nvidia0 ] && export GSK_RENDERER=opengl
		export SERVER_PATH="${EPREFIX}/usr/libexec/stremio/server.js"
		exec "${EPREFIX}/usr/libexec/stremio/stremio" "\$@"
	EOF

	# build.rs runs msgfmt without waiting for it; compile the
	# catalogs here instead of relying on its output.
	local po lang
	for po in po/*.po; do
		lang=$(basename "${po}" .po)
		msgfmt -o "${T}/${lang}.mo" "${po}" || die
		insinto /usr/share/locale/${lang}/LC_MESSAGES
		newins "${T}/${lang}.mo" stremio.mo
	done

	insinto /usr/share/glib-2.0/schemas
	doins data/com.stremio.Stremio.gschema.xml

	domenu data/com.stremio.Stremio.desktop
	insinto /usr/share/metainfo
	doins data/com.stremio.Stremio.metainfo.xml
	doman data/stremio.1

	sed -e "s|/app/bin/stremio|${EPREFIX}/usr/bin/stremio|" \
		data/com.stremio.Stremio.service > "${T}"/com.stremio.Stremio.service || die
	insinto /usr/share/dbus-1/services
	doins "${T}"/com.stremio.Stremio.service

	doicon -s scalable data/icons/com.stremio.Stremio.svg
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
