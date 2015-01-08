class Llvm35WithArm < Formula
  homepage  'http://llvm.org/'

  stable do
    url 'http://llvm.org/releases/3.5.0/llvm-3.5.0.src.tar.xz'
    sha1 '58d817ac2ff573386941e7735d30702fe71267d5'

    resource 'clang' do
      url 'http://llvm.org/releases/3.5.0/cfe-3.5.0.src.tar.xz'
      sha1 '834cee2ed8dc6638a486d8d886b6dce3db675ffa'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/releases/3.5.0/clang-tools-extra-3.5.0.src.tar.xz'
      sha1 '74a84493e3313c180490a4affbb92d61ee4f0d21'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/releases/3.5.0/compiler-rt-3.5.0.src.tar.xz'
      sha1 '61f3e78088ce4a0787835036f2d3c61ede11e928'
    end

    resource 'polly' do
      url 'http://llvm.org/releases/3.5.0/polly-3.5.0.src.tar.xz'
      sha1 '74a2c80f12dc2645e4e77d330c8b7e0f53a5709c'
    end

    resource 'lld' do
      url 'http://llvm.org/releases/3.5.0/lld-3.5.0.src.tar.xz'
      sha1 '13c88e1442b482b3ffaff5934f0a2b51cab067e5'
    end

    resource 'libcxx' do
      url 'http://llvm.org/releases/3.5.0/libcxx-3.5.0.src.tar.xz'
      sha1 'c98beed86ae1adf9ab7132aeae8fd3b0893ea995'
    end

    resource 'libcxxabi' do
      url 'http://llvm.org/releases/3.5.0/libcxxabi-3.5.0.src.tar.xz'
      sha1 '31ffde04899449ae754a39c3b4e331a73a51a831'
    end if MacOS.version <= :snow_leopard
  end

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/versions"
    revision 1
    sha1 "40acdee096ab4c536ebde72220986cd160b9432a" => :yosemite
    sha1 "ac92d8f6bf0e7127c940671869aeac39d06dd636" => :mavericks
    sha1 "f1f245d80d26d539327c88feeaa90aefdbf2eaa8" => :mountain_lion
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_35"

    resource 'clang' do
      url 'http://llvm.org/git/clang.git', :branch => 'release_35'
    end

    resource 'clang-tools-extra' do
      url 'http://llvm.org/git/clang-tools-extra.git', :branch => 'release_35'
    end

    resource 'compiler-rt' do
      url 'http://llvm.org/git/compiler-rt.git', :branch => 'release_35'
    end

    resource 'polly' do
      url 'http://llvm.org/git/polly.git', :branch => 'release_35'
    end

    resource 'lld' do
      url 'http://llvm.org/git/lld.git'
    end

    resource 'libcxx' do
      url 'http://llvm.org/git/libcxx.git', :branch => 'release_35'
    end

    resource 'libcxxabi' do
      url 'http://llvm.org/git/libcxxabi.git'
    end if MacOS.version <= :snow_leopard
  end

  resource 'isl' do
    url 'http://isl.gforge.inria.fr/isl-0.13.tar.bz2'
    sha1 '3904274c84fb3068e4f59b6a6b0fe29e7a2b7010'
  end

  resource 'cloog' do
    url 'http://repo.or.cz/w/cloog.git/snapshot/22643c94eba7b010ae4401c347289f4f52b9cd2b.tar.gz'
    sha1 '5409629e2fbe38035e8071c81601317a1a699309'
  end

  patch :DATA

  option :universal
  option 'with-lld', 'Build LLD linker'
  option 'with-asan', 'Include support for -faddress-sanitizer (from compiler-rt)'
  option 'disable-shared', "Don't build LLVM as a shared library"
  option 'all-targets', 'Build all target backends'
  option 'disable-assertions', 'Speeds up LLVM, but provides less debug information'

  # required to build cloog
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build
  depends_on "pkg-config" => :build

  depends_on 'gmp'
  depends_on 'libffi' => :recommended

  def ver; '3.5'; end # version suffix

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    clang_buildpath = buildpath/"tools/clang"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"tools/lld").install resource("lld") if build.with? "lld"
    (buildpath/"projects/compiler-rt").install resource("compiler-rt") if build.with? "asan"

    ENV['REQUIRES_RTTI'] = '1'

    install_prefix = lib/"llvm-#{ver}"

    gmp_prefix = Formula["gmp"].opt_prefix
    isl_prefix = install_prefix/'libexec/isl'
    cloog_prefix = install_prefix/'libexec/cloog'

    resource('isl').stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{isl_prefix}",
                            "--with-gmp=system",
                            "--with-gmp-prefix=#{gmp_prefix}"
      system "make"
      system "make", "install"
    end

    resource('cloog').stage do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{cloog_prefix}",
                            "--with-gmp-prefix=#{gmp_prefix}",
                            "--with-isl-prefix=#{isl_prefix}"
      system "make"
      system "make", "install"
    end

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--disable-bindings",
      "--with-gmp=#{gmp_prefix}",
      "--with-isl=#{isl_prefix}",
      "--with-cloog=#{cloog_prefix}",
      "--enable-targets=arm,x86,x86_64"
    ]

    args << "--enable-shared" unless build.include? 'disable-shared'

    args << "--disable-assertions" if build.include? 'disable-assertions'

    args << "--enable-libffi" if build.with? 'libffi'

    system './configure', '--enable-targets=arm', *args
    system 'make', '-j', '12', 'VERBOSE=1'
    system 'make', 'VERBOSE=1', 'install'

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/'lib' do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV['CC'] = "#{install_prefix}/bin/clang"
        ENV['CXX'] = "#{install_prefix}/bin/clang++"
        ENV['TRIPLE'] = "*-apple-*"
        system "./buildit"
        (install_prefix/"usr/lib").install "libc++abi.dylib"
        cp libcxxabi_buildpath/"include/cxxabi.h", install_prefix/"lib/c++/v1"
      end

      # Snow Leopard make rules hardcode libc++ and libc++abi path.
      # Change to Cellar path here.
      inreplace "#{libcxx_buildpath}/lib/buildit" do |s|
        s.gsub! "-install_name /usr/lib/libc++.1.dylib", "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        s.gsub! "-Wl,-reexport_library,/usr/lib/libc++abi.dylib", "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/"include/cxxabi.h", libcxx_buildpath/"include"
    end

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    libcxx_make_args = [
      # Use the built clang for building
      "CC=#{install_prefix}/bin/clang",
      "CXX=#{install_prefix}/bin/clang++",
      # Properly set deployment target, which is needed for Snow Leopard
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      # The following flags are needed so it can be installed correctly.
      "DSTROOT=#{install_prefix}",
      "SYMROOT=#{libcxx_buildpath}"
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang-#{ver}/tools").install Dir["tools/clang/tools/scan-{build,view}"]

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
      clang_buildpath/"bindings/python/clang" => "clang-#{ver}"

    Dir.glob(install_prefix/'bin/*') do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/'share/man/man1/*') do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  test do
    system "#{bin}/llvm-config-#{ver}", "--version"
  end

  def caveats; <<-EOS.undent
    Extra tools are installed in #{opt_share}/clang-#{ver}

    To link to libc++, something like the following is required:
      CXX="clang++-#{ver} -stdlib=libc++"
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/include/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end
end

__END__
diff --git a/Makefile.rules b/Makefile.rules
index ebebc0a..b0bb378 100644
--- a/Makefile.rules
+++ b/Makefile.rules
@@ -599,7 +599,12 @@ ifneq ($(HOST_OS), $(filter $(HOST_OS), Cygwin MingW))
 ifneq ($(HOST_OS),Darwin)
   LD.Flags += $(RPATH) -Wl,'$$ORIGIN'
 else
-  LD.Flags += -Wl,-install_name  -Wl,"@rpath/lib$(LIBRARYNAME)$(SHLIBEXT)"
+  LD.Flags += -Wl,-install_name
+  ifdef LOADABLE_MODULE
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(LIBRARYNAME)$(SHLIBEXT)"
+  else
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)"
+  endif
 endif
 endif
 endif
