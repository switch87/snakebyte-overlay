# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

declare -A GIT_CRATES=(
[glib] = "https://github.com/gtk-rs/gtk-rs-core;2ed8c82f24d956a180a1d2dcf98a0a66a70b802c"
[gio] = "https://github.com/gtk-rs/gtk-rs-core;2ed8c82f24d956a180a1d2dcf98a0a66a70b802c"
[cairo-rs] = "https://github.com/gtk-rs/gtk-rs-core;2ed8c82f24d956a180a1d2dcf98a0a66a70b802c"
[pango] = "https://github.com/gtk-rs/gtk-rs-core;2ed8c82f24d956a180a1d2dcf98a0a66a70b802c"
pangocairo = "https://github.com/gtk-rs/gtk-rs-core;2ed8c82f24d956a180a1d2dcf98a0a66a70b802c"
gtk = { package = "gtk4", git = "https://github.com/gtk-rs/gtk4-rs", branch = "main", features = ["v4_6"], version = "0.12.0-alpha" }
gdk-wayland = { package = "gdk4-wayland", git = "https://github.com/gtk-rs/gtk4-rs", branch = "main", features = ["v4_4"], version = "0.12.0-alpha" }
gdk-x11 = { package = "gdk4-x11", git = "https://github.com/gtk-rs/gtk4-rs", branch = "main", features = ["v4_4"], version = "0.12.0-alpha" }
gdk-win32 = { package = "gdk4-win32", git = "https://github.com/gtk-rs/gtk4-rs", branch = "main", features = ["v4_4"], version = "0.12.0-alpha" }
gst = { package = "gstreamer", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-allocators = { package = "gstreamer-allocators", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-analytics = { package = "gstreamer-analytics", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-app = { package = "gstreamer-app", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-audio = { package = "gstreamer-audio", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-base = { package = "gstreamer-base", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-check = { package = "gstreamer-check", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-gl = { package = "gstreamer-gl", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-gl-egl = { package = "gstreamer-gl-egl", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-gl-wayland = { package = "gstreamer-gl-wayland", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-gl-x11 = { package = "gstreamer-gl-x11", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-net = { package = "gstreamer-net", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-pbutils = { package = "gstreamer-pbutils", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-plugin-version-helper = { path="./version-helper", version = "0.8" }
gst-rtp = { package = "gstreamer-rtp", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-sdp = { package = "gstreamer-sdp", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-tag = { package = "gstreamer-tag", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-tracing = { package = "gstreamer-tracing", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-utils = { package = "gstreamer-utils", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-validate = { package = "gstreamer-validate", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-video = { package = "gstreamer-video", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
gst-webrtc = { package = "gstreamer-webrtc", git = "https://gitlab.freedesktop.org/gstreamer/gstreamer-rs", branch = "main", version = "0.26.0-alpha" }
)

CRATES="
gst-plugin-webrtc-signalling-protocol@0.16.0-alpha
gst-plugin-webrtc-signalling@0.16.0-alpha
gst-plugin-isobmff@0.16.0-alpha
gst-plugin-gtk4@0.16.0-alpha
gst-plugin-rtp@0.16.0-alpha
gst-plugin-hlssink3@0.16.0-alpha
"

inherit cargo meson xdg

DESCRIPTION="GStreamer plugins written in Rust"
HOMEPAGE="https://gstreamer.freedesktop.org/"
SRC_URI="
https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/archive/gstreamer-${PV}/gst-plugins-rs-gstreamer-${PV}.tar.gz
${CARGO_CRATE_URIS}
"

S="${WORKDIR}/gst-plugins-rs-gstreamer-${PV}"

LICENSE="|| ( LGPL-2.1+ MIT Apache-2.0 MPL-2.0 )"
SLOT="1.0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk spotify"

DEPEND="
media-libs/gstreamer:1.0
media-libs/gst-plugins-base:1.0
media-libs/dav1d
dev-libs/libsodium
	media-libs/libwebp
gtk? ( gui-libs/gtk:4 )

	"

	RDEPEND="${DEPEND}"
	DEPEND="virtual/pkgconfig"

	src_configure() {
		local emesonargs=(
				$(meson_feature spotify)
				$(meson_feature gtk gtk4)
				-Ddoc=disabled
				)
			meson_src_configure
	}
