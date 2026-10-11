# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{11..14} )

CRATES="
	aho-corasick@1.1.5
	android_system_properties@0.1.6
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.104
	async-trait@0.1.92
	autocfg@1.5.1
	bitflags@1.3.2
	bitflags@2.13.2
	bumpalo@3.20.3
	bytes@1.12.1
	cc@1.4.7
	cfg-if@1.0.5
	cfg_aliases@0.2.2
	chrono@0.4.45
	colorchoice@1.0.5
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	crunchy@0.2.4
	defmt-macros@1.1.1
	defmt-parser@1.0.0
	defmt@1.1.1
	deranged@0.5.8
	either@1.18.0
	env_filter@0.1.4
	env_filter@2.0.0
	env_logger@0.11.11
	equivalent@1.0.2
	find-msvc-tools@0.1.13
	futures-core@0.3.34
	futures-sink@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	getopts@0.2.24
	getrandom@0.2.17
	hashbrown@0.17.1
	heck@0.5.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	indexmap@2.14.2
	inventory@0.3.24
	io-kit-sys@0.4.1
	is-macro@0.3.8
	is_terminal_polyfill@1.70.2
	itertools@0.11.0
	itertools@0.14.0
	itoa@1.0.18
	jiff-core@0.1.1
	jiff-static@0.2.37
	jiff@0.2.37
	js-sys@0.3.105
	lalrpop-util@0.20.2
	libc@0.2.189
	log@0.4.34
	mach2@0.4.3
	maplit@1.0.2
	matrixmultiply@0.3.11
	memchr@2.8.3
	mio-serial@5.0.7
	mio@1.2.3
	ndarray@0.17.2
	nix@0.26.4
	nix@0.31.3
	num-bigint@0.4.8
	num-complex@0.4.6
	num-conv@0.2.2
	num-integer@0.1.47
	num-traits@0.2.19
	numpy@0.28.0
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	ordered-float@5.5.0
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_shared@0.11.3
	pin-project-lite@0.2.17
	portable-atomic-util@0.2.8
	portable-atomic@1.15.0
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	proc-macro2@1.0.107
	pyo3-build-config@0.28.3
	pyo3-ffi@0.28.3
	pyo3-macros-backend@0.28.3
	pyo3-macros@0.28.3
	pyo3-stub-gen-derive@0.23.0
	pyo3-stub-gen@0.23.0
	pyo3@0.28.3
	quote@1.0.47
	rand@0.8.8
	rand_chacha@0.3.1
	rand_core@0.6.4
	rawpointer@0.2.1
	regex-automata@0.4.18
	regex-syntax@0.8.11
	regex@1.13.1
	rustc-hash@1.1.0
	rustc-hash@2.1.3
	rustpython-ast@0.4.0
	rustpython-parser-core@0.4.0
	rustpython-parser-vendored@0.4.0
	rustpython-parser@0.4.0
	rustversion@1.0.23
	scopeguard@1.2.0
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_spanned@1.1.1
	serialport@4.10.1
	shlex@2.0.1
	siphasher@1.0.3
	slab@0.4.12
	socket2@0.6.5
	static_assertions@1.1.0
	syn@2.0.119
	syn@3.0.6
	target-lexicon@0.13.5
	thiserror-impl@2.0.20
	thiserror@2.0.20
	time-core@0.1.9
	time@0.3.55
	tiny-keccak@2.0.2
	tokio-macros@2.7.2
	tokio-serial@5.5.0
	tokio@1.53.1
	toml@1.1.6+spec-1.1.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_parser@1.1.3+spec-1.1.0
	toml_writer@1.1.2+spec-1.1.0
	unescaper@0.1.10
	unic-char-property@0.9.0
	unic-char-range@0.9.0
	unic-common@0.9.0
	unic-emoji-char@0.9.0
	unic-ucd-ident@0.9.0
	unic-ucd-version@0.9.0
	unicode-ident@1.0.26
	unicode-width@0.2.2
	unicode_names2@1.3.0
	unicode_names2_generator@1.3.0
	utf8parse@0.2.2
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen-macro-support@0.2.128
	wasm-bindgen-macro@0.2.128
	wasm-bindgen-shared@0.2.128
	wasm-bindgen@0.2.128
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
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
	winnow@1.0.4
	zerocopy-derive@0.8.57
	zerocopy@0.8.57
	zmij@1.0.23
"

inherit cargo distutils-r1 pypi

DESCRIPTION="Rust-native machine drivers for Rayforge, with Python bindings"
HOMEPAGE="
	https://github.com/barebaric/raydriver
	https://pypi.org/project/raydriver/
"
SRC_URI+="
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 CC0-1.0 MIT MPL-2.0
	Unicode-3.0 Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="~amd64"

QA_FLAGS_IGNORED="usr/lib.*/py.*/site-packages/raydriver/.*\\.so"

# pyo3 0.28 abi3-py311 wheel is built once per impl; keep it simple and
# let distutils-r1 do per-impl builds
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

src_unpack() {
	cargo_src_unpack
}

EPYTEST_PLUGINS=( pytest-asyncio pytest-timeout )
distutils_enable_tests pytest
