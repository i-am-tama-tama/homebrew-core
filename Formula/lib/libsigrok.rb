class Libsigrok < Formula
  desc "Drivers for logic analyzers and other supported devices"
  homepage "https://sigrok.org/"
  # libserialport is LGPL3+
  # fw-fx2lafw is GPL-2.0-or-later and LGPL-2.1-or-later"
  license all_of: ["GPL-3.0-or-later", "LGPL-3.0-or-later", "GPL-2.0-or-later", "LGPL-2.1-or-later"]
  revision 4

  stable do
    url "https://sigrok.org/download/source/libsigrok/libsigrok-0.5.2.tar.gz"
    sha256 "4d341f90b6220d3e8cb251dacf726c41165285612248f2c52d15df4590a1ce3c"

    resource "libserialport" do
      url "https://sigrok.org/download/source/libserialport/libserialport-0.1.1.tar.gz"
      sha256 "4a2af9d9c3ff488e92fb75b4ba38b35bcf9b8a66df04773eba2a7bbf1fa7529d"
    end

    resource "fw-fx2lafw" do
      url "https://sigrok.org/download/source/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-0.1.7.tar.gz"
      sha256 "a3f440d6a852a46e2c5d199fc1c8e4dacd006bc04e0d5576298ee55d056ace3b"

      # Backport fixes to build with sdcc>=4.2.3. Remove in the next release of fw-fx2lafw.
      patch do
        url "https://sigrok.org/gitweb/?p=sigrok-firmware-fx2lafw.git;a=commitdiff_plain;h=5aab87d358a4585a10ad89277bb88ad139077abd"
        sha256 "ddf21e9e655c78d93cb58742e1a4dcbe769dfa2d88cfc963f97b6e5794c2fdcf"
      end
      patch do
        url "https://sigrok.org/gitweb/?p=sigrok-firmware-fx2lafw.git;a=commitdiff_plain;h=3e08500d22f87f69941b65cf8b8c1b85f9b41173"
        sha256 "dd74b58ae0e255bca4558dc6604e32c34c49ddb05281d7edc35495f0c506373a"
      end
      patch do
        url "https://sigrok.org/gitweb/?p=sigrok-firmware-fx2lafw.git;a=commitdiff_plain;h=96b0b476522c3f93a47ff8f479ec08105ba6a2a5"
        sha256 "b75c7b6a1705e2f8d97d5bdaac01d1ae2476c0b0f1b624d766d722dd12b402db"
      end
    end
  end

  livecheck do
    url "https://sigrok.org/wiki/Downloads"
    regex(/href=.*?libsigrok[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 1
    sha256                               arm64_sonoma:   "25451aaa30807a512ee33dab2c5e84a0d6a9248cc345bea3d314e4e9871c3d7e"
    sha256                               arm64_ventura:  "d5a91f7b194fdeff5f9dbccdaf47e42ae20eef9b5885ce4c195656ee3a4e50a4"
    sha256                               arm64_monterey: "4b977b13bc1aa1e9290f9b8b5994b7ca95572f4d963a806390be234b4bd2540f"
    sha256                               sonoma:         "8f439b415662863d7e6c9d14524cea2479fbad8e64f9b59a73bba4d2887de80c"
    sha256                               ventura:        "3c3e878899fa1538c53c8981886ddacd868f9fc726bfb3d2d707afbb5f961bce"
    sha256                               monterey:       "77caa1c69e1d0f7e5e0be2de793f9f684b9c02b40bc11dbf9b2e5e22ad287298"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3e8328d0d3fb80d6ccb0499cae7ec7cb3e6643abf1fb3064b51923f45b6357f8"
  end

  head do
    url "git://sigrok.org/libsigrok", branch: "master"

    resource "libserialport" do
      url "git://sigrok.org/libserialport", branch: "master"
    end

    resource "fw-fx2lafw" do
      url "git://sigrok.org/sigrok-firmware-fx2lafw", branch: "master"
    end
  end

  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "python-setuptools" => :build
  depends_on "sdcc" => :build
  depends_on "swig" => :build
  depends_on "glib"
  depends_on "glibmm@2.66"
  depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libzip"
  depends_on "nettle"
  depends_on "numpy"
  depends_on "pygobject3"
  depends_on "python@3.12"

  on_macos do
    depends_on "gettext"
    depends_on "libsigc++@2"
  end

  resource "fw-fx2lafw" do
    url "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.7.tar.gz"
    sha256 "c876fd075549e7783a6d5bfc8d99a695cfc583ddbcea0217d8e3f9351d1723af"
  end

  def python3
    "python3.12"
  end

  def install
    resource("fw-fx2lafw").stage do
      if build.head?
        system "./autogen.sh"
      else
        system "autoreconf", "--force", "--install", "--verbose"
      end

      mkdir "build" do
        system "../configure", *std_configure_args
        system "make", "install"
      end
    end

    resource("libserialport").stage do
      if build.head?
        system "./autogen.sh"
      else
        system "autoreconf", "--force", "--install", "--verbose"
      end

      mkdir "build" do
        system "../configure", *std_configure_args
        system "make", "install"
      end
    end

    # We need to use the Makefile to generate all of the dependencies
    # for setup.py, so the easiest way to make the Python libraries
    # work is to adjust setup.py's arguments here.
    prefix_site_packages = prefix/Language::Python.site_packages(python3)
    inreplace "Makefile.am" do |s|
      s.gsub!(/^(setup_py =.*setup\.py .*)/, "\\1 --no-user-cfg")
      s.gsub!(
        /(\$\(setup_py\) install)/,
        "\\1 --single-version-externally-managed --record=installed.txt --install-lib=#{prefix_site_packages}",
      )
    end

    if build.head?
      system "./autogen.sh"
    else
      system "autoreconf", "--force", "--install", "--verbose"
    end

    mkdir "build" do
      ENV["PYTHON"] = python3
      ENV.prepend_path "PKG_CONFIG_PATH", lib/"pkgconfig"
      args = %w[
        --disable-java
        --disable-ruby
      ]
      system "../configure", *std_configure_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libsigrok/libsigrok.h>

      int main() {
        struct sr_context *ctx;
        if (sr_init(&ctx) != SR_OK) {
           exit(EXIT_FAILURE);
        }
        if (sr_exit(ctx) != SR_OK) {
           exit(EXIT_FAILURE);
        }
        return 0;
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libsigrok").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"

    system python3, "-c", <<~EOS
      import sigrok.core as sr
      sr.Context.create()
    EOS
  end
end
