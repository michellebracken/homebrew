class ClutterGst < Formula
  desc "ClutterMedia interface using GStreamer for video and audio"
  homepage "https://developer.gnome.org/clutter-gst/"
  url "https://download.gnome.org/sources/clutter-gst/3.0/clutter-gst-3.0.6.tar.xz"
  sha256 "d6d5493ae57cc175deee479304569c419d2bb90de3be124e6f3350ae7e73df76"

  bottle do
    sha256 "eb342390403c07b551eb58a94d5732ae1584177e95038f1ebf11c4ba32529852" => :yosemite
    sha256 "1cd6f55121d1f07a9fe7717564305dd7a8db36a0e370ea05157bbf8efd4db84f" => :mavericks
    sha256 "270d6c064aa2708db4f71a22fce4a82a1f0cd5010e7aa0210a6bb9e55664c5e9" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "clutter"
  depends_on "gstreamer"
  depends_on "gst-plugins-base"
  depends_on "gdk-pixbuf"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-debug
      --prefix=#{prefix}
      --enable-introspection=yes
      --disable-silent-rules
      --disable-gtk-doc-html
    ]

    # the source code requires gdk-pixbuf but configure doesn't look for it
    ENV.append "CFLAGS", `pkg-config --cflags gdk-pixbuf-2.0`.chomp
    ENV.append "LIBS", `pkg-config --libs gdk-pixbuf-2.0`.chomp

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <clutter-gst/clutter-gst.h>

      int main(int argc, char *argv[]) {
        clutter_gst_init(&argc, &argv);
        return 0;
      }
    EOS
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    clutter = Formula["clutter"]
    cogl = Formula["cogl"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gst_plugins_base = Formula["gst-plugins-base"]
    gstreamer = Formula["gstreamer"]
    json_glib = Formula["json-glib"]
    libpng = Formula["libpng"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{clutter.opt_include}/clutter-1.0
      -I#{cogl.opt_include}/cogl
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gst_plugins_base.opt_include}/gstreamer-1.0
      -I#{gstreamer.opt_include}/gstreamer-1.0
      -I#{include}/clutter-gst-3.0
      -I#{json_glib.opt_include}/json-glib-1.0
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{clutter.opt_lib}
      -L#{cogl.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gst_plugins_base.opt_lib}
      -L#{gstreamer.opt_lib}
      -L#{json_glib.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lclutter-1.0
      -lclutter-gst-3.0
      -lcogl
      -lcogl-pango
      -lcogl-path
      -lgio-2.0
      -lglib-2.0
      -lgmodule-2.0
      -lgobject-2.0
      -lgstbase-1.0
      -lgstreamer-1.0
      -lgstvideo-1.0
      -lintl
      -ljson-glib-1.0
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
