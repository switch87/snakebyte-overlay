EAPI=8

DESCRIPTION="Stremio - The freedom to stream"
HOMEPAGE="https://www.stremio.com"
S="${WORKDIR}/stremio-linux-shell-1.0.0-beta.12"
SRC_URI="https://github.com/Stremio/stremio-linux-shell/archive/refs/tags/v1.0.0-beta.12.tar.gz -> ${P}.tar.gz
    https://cef-builds.spotifycdn.com/cef_binary_138.0.21+g54811fe+chromium-138.0.7204.101_linux64_minimal.tar.bz2
    https://github.com/Stremio/cef-rs/archive/8aa6a6aa6e3b621e9a571a34b64e90f1a574277b.tar.gz -> cef-rs-8aa6a6aa6e3b621e9a571a34b64e90f1a574277b.tar.gz
    https://github.com/Stremio/glutin/archive/7d45516496d1783ba37fa94ebdd255272605892c.tar.gz -> glutin-7d45516496d1783ba37fa94ebdd255272605892c.tar.gz
    https://github.com/Stremio/winit/archive/dbb55e126896887283c269c4460d0d7f80349012.tar.gz -> winit-dbb55e126896887283c269c4460d0d7f80349012.tar.gz
    https://github.com/Stremio/libmpv2-rs/archive/b2b0ce03fde964c0c5cd4f66e193740062468b41.tar.gz -> libmpv2-rs-b2b0ce03fde964c0c5cd4f66e193740062468b41.tar.gz"

LICENSE="GPL-3.0-only"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

DEPEND="
    dev-lang/rust
    dev-libs/openssl
    dev-libs/nss
    media-video/mpv
    x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"

src_prepare() {
    default

    mkdir -p "${S}/vendor"
    tar -xf "${DISTDIR}/cef-rs-8aa6a6aa6e3b621e9a571a34b64e90f1a574277b.tar.gz" -C "${S}/vendor"
    tar -xf "${DISTDIR}/glutin-7d45516496d1783ba37fa94ebdd255272605892c.tar.gz" -C "${S}/vendor"
    tar -xf "${DISTDIR}/winit-dbb55e126896887283c269c4460d0d7f80349012.tar.gz" -C "${S}/vendor"
    tar -xf "${DISTDIR}/libmpv2-rs-b2b0ce03fde964c0c5cd4f66e193740062468b41.tar.gz" -C "${S}/vendor"

    # Unpack CEF binary
    mkdir -p "${S}/cef_binary"
    tar -xf "${DISTDIR}/cef_binary_138.0.21+g54811fe+chromium-138.0.7204.101_linux64_minimal.tar.bz2" -C "${S}/cef_binary" --strip-components=1

    # Create the cargo config
    cat > "${S}/.cargo/config.toml" <<-EOF
[patch.'https://github.com/Stremio/cef-rs']
cef = { path = "${S}/vendor/cef-rs-8aa6a6aa6e3b621e9a571a34b64e90f1a574277b/cef" }
cef-dll-sys = { path = "${S}/vendor/cef-rs-8aa6a6aa6e3b621e9a571a34b64e90f1a574277b/sys" }

[patch.'https://github.com/Stremio/glutin']
glutin = { path = "${S}/vendor/glutin-7d45516496d1783ba37fa94ebdd255272605892c/glutin" }
glutin-winit = { path = "${S}/vendor/glutin-7d45516496d1783ba37fa94ebdd255272605892c/glutin-winit" }

[patch.'https://github.com/Stremio/libmpv2-rs']
libmpv2 = { path = "${S}/vendor/libmpv2-rs-b2b0ce03fde964c0c5cd4f66e193740062468b41" }

[patch.'https://github.com/Stremio/winit']
winit = { path = "${S}/vendor/winit-dbb55e126896887283c269c4460d0d7f80349012" }
EOF
}

src_compile() {
    export CEF_PATH="${S}/cef_binary"
    export CARGO_REGISTRY_PROTOCOL=http
    export CARGO_HTTP_MULTIPLEXING=false
    cargo build --release --target-dir "${S}/target"
}

src_install() {
    dobin "${S}/target/release/stremio-linux-shell" "${D}/usr/bin/stremio"
    insinto /usr/share/applications
    doins data/com.stremio.Stremio.desktop
    insinto /usr/share/metainfo
    doins data/com.stremio.Stremio.metainfo.xml
    insinto /usr/share/icons/hicolor/scalable/apps
    doins data/icons/com.stremio.Stremio.svg
}