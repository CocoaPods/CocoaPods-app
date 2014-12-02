DEPLOYMENT_TARGET = '10.8'
DEPLOYMENT_TARGET_SDK = "MacOSX#{DEPLOYMENT_TARGET}.sdk"

$build_started_at = Time.now

# OpenSSL fails if we set this make configuration through MAKEFLAGS, so we pass
# it to each make invocation seperately.
MAKE_CONCURRENCY = `sysctl hw.physicalcpu`.strip.match(/\d+$/)[0].to_i + 1

PKG_DIR = 'pkg'
DOWNLOAD_DIR = 'downloads'
WORKBENCH_DIR = 'workbench'
DESTROOT = 'destroot'
BUNDLE_DESTROOT = File.join(DESTROOT, 'bundle')
DEPENDENCIES_DESTROOT = File.join(DESTROOT, 'dependencies')

PATCHES_DIR = File.expand_path('patches')
BUNDLE_PREFIX = File.expand_path(BUNDLE_DESTROOT)
DEPENDENCIES_PREFIX = File.expand_path(DEPENDENCIES_DESTROOT)

directory PKG_DIR
directory DOWNLOAD_DIR
directory WORKBENCH_DIR
directory DEPENDENCIES_DESTROOT

# Prefer the SDK of the DEPLOYMENT_TARGET, but otherwise fallback to the current one.
sdk_dir = File.join(`xcrun --show-sdk-platform-path --sdk macosx`.strip, 'Developer/SDKs')
if Dir.entries(sdk_dir).include?(DEPLOYMENT_TARGET_SDK)
  SDKROOT = File.join(sdk_dir, DEPLOYMENT_TARGET_SDK)
else
  SDKROOT = File.expand_path(`xcrun --show-sdk-path --sdk macosx`.strip)
end
unless File.exist?(SDKROOT)
  puts "[!] Unable to find a SDK for the Platform target `macosx`."
  exit 1
end

ENV['PATH'] = "#{File.join(DEPENDENCIES_PREFIX, 'bin')}:/usr/bin:/bin"
ENV['CC'] = '/usr/bin/clang'
ENV['CXX'] = '/usr/bin/clang++'
ENV['CFLAGS'] = "-I#{File.join(DEPENDENCIES_PREFIX, 'include')} -mmacosx-version-min=#{DEPLOYMENT_TARGET} -isysroot #{SDKROOT}"
ENV['LDFLAGS'] = "-L#{File.join(DEPENDENCIES_PREFIX, 'lib')}"

# If we don't create this dir and set the env var, the ncurses configure
# script will simply decide that we don't want any .pc files.
PKG_CONFIG_LIBDIR = File.join(DEPENDENCIES_PREFIX, 'lib/pkgconfig')
ENV['PKG_CONFIG_LIBDIR'] = PKG_CONFIG_LIBDIR

# Defaults to the latest available version or the VERSION env variable.
def install_cocoapods_version
  return @install_cocoapods_version if @install_cocoapods_version
  return @install_cocoapods_version = ENV['VERSION'] if ENV['VERSION']

  sh "pod repo update master"
  version_file = File.expand_path('~/.cocoapods/repos/master/CocoaPods-version.yml')
  require 'yaml'
  @install_cocoapods_version = YAML.load(File.read(version_file))['last']
end

# ------------------------------------------------------------------------------
# Package metadata
# ------------------------------------------------------------------------------

PKG_CONFIG_VERSION = '0.28'
PKG_CONFIG_URL = "http://pkg-config.freedesktop.org/releases/pkg-config-#{PKG_CONFIG_VERSION}.tar.gz"

LIBYAML_VERSION = '0.1.6'
LIBYAML_URL = "http://pyyaml.org/download/libyaml/yaml-#{LIBYAML_VERSION}.tar.gz"

ZLIB_VERSION = '1.2.8'
ZLIB_URL = "http://zlib.net/zlib-#{ZLIB_VERSION}.tar.gz"

OPENSSL_VERSION = '1.0.1j'
OPENSSL_URL = "https://www.openssl.org/source/openssl-#{OPENSSL_VERSION}.tar.gz"

NCURSES_VERSION = '5.9'
NCURSES_URL = "http://ftpmirror.gnu.org/ncurses/ncurses-#{NCURSES_VERSION}.tar.gz"

READLINE_VERSION = '6.3'
READLINE_URL = "http://ftpmirror.gnu.org/readline/readline-#{READLINE_VERSION}.tar.gz"

LIBFFI_VERSION = '3.1'
LIBFFI_URL = "ftp://sourceware.org/pub/libffi/libffi-#{LIBFFI_VERSION}.tar.gz"

RUBY__VERSION = '2.1.4'
RUBY_URL = "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-#{RUBY__VERSION}.tar.gz"

GIT_VERSION = '2.1.3'
GIT_URL = "https://www.kernel.org/pub/software/scm/git/git-#{GIT_VERSION}.tar.gz"

SCONS_URL = "http://prdownloads.sourceforge.net/scons/scons-local-2.3.4.tar.gz"
SERF_URL = "http://serf.googlecode.com/svn/src_releases/serf-1.3.8.tar.bz2"
SVN_URL = "http://apache.hippo.nl/subversion/subversion-1.8.10.tar.gz"

BZR_URL = "https://launchpad.net/bzr/2.6/2.6.0/+download/bzr-2.6.0.tar.gz"

MERCURIAL_URL = "http://mercurial.selenic.com/release/mercurial-3.2.tar.gz"

# ------------------------------------------------------------------------------
# pkg-config
# ------------------------------------------------------------------------------

pkg_config_tarball = File.join(DOWNLOAD_DIR, File.basename(PKG_CONFIG_URL))
file pkg_config_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{PKG_CONFIG_URL} -o #{pkg_config_tarball}"
end

pkg_config_build_dir = File.join(WORKBENCH_DIR, File.basename(PKG_CONFIG_URL, '.tar.gz'))
directory pkg_config_build_dir => [pkg_config_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{pkg_config_tarball} -C #{WORKBENCH_DIR}"
end

pkg_config_bin = File.join(pkg_config_build_dir, 'pkg-config')
file pkg_config_bin => pkg_config_build_dir do
  sh "cd #{pkg_config_build_dir} && ./configure --enable-static --with-internal-glib --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{pkg_config_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_pkg_config = File.join(DEPENDENCIES_DESTROOT, 'bin/pkg-config')
file installed_pkg_config => pkg_config_bin do
  sh "cd #{pkg_config_build_dir} && make install"
  mkdir_p PKG_CONFIG_LIBDIR
end

# ------------------------------------------------------------------------------
# YAML
# ------------------------------------------------------------------------------

yaml_tarball = File.join(DOWNLOAD_DIR, File.basename(LIBYAML_URL))
file yaml_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{LIBYAML_URL} -o #{yaml_tarball}"
end

yaml_build_dir = File.join(WORKBENCH_DIR, File.basename(LIBYAML_URL, '.tar.gz'))
directory yaml_build_dir => [yaml_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{yaml_tarball} -C #{WORKBENCH_DIR}"
end

yaml_static_lib = File.join(yaml_build_dir, 'src/.libs/libyaml.a')
file yaml_static_lib => [installed_pkg_config, yaml_build_dir] do
  sh "cd #{yaml_build_dir} && ./configure --disable-shared --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{yaml_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_yaml = File.join(DEPENDENCIES_DESTROOT, 'lib/libyaml.a')
file installed_yaml => yaml_static_lib do
  sh "cd #{yaml_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# ZLIB
# ------------------------------------------------------------------------------

zlib_tarball = File.join(DOWNLOAD_DIR, File.basename(ZLIB_URL))
file zlib_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{ZLIB_URL} -o #{zlib_tarball}"
end

zlib_build_dir = File.join(WORKBENCH_DIR, File.basename(ZLIB_URL, '.tar.gz'))
directory zlib_build_dir => [zlib_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{zlib_tarball} -C #{WORKBENCH_DIR}"
end

zlib_static_lib = File.join(zlib_build_dir, 'libz.a')
file zlib_static_lib => [installed_pkg_config, zlib_build_dir] do
  sh "cd #{zlib_build_dir} && ./configure --static --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{zlib_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_zlib = File.join(DEPENDENCIES_DESTROOT, 'lib/libz.a')
file installed_zlib => zlib_static_lib do
  sh "cd #{zlib_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# OpenSSL
# ------------------------------------------------------------------------------

openssl_tarball = File.join(DOWNLOAD_DIR, File.basename(OPENSSL_URL))
file openssl_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{OPENSSL_URL} -o #{openssl_tarball}"
end

openssl_build_dir = File.join(WORKBENCH_DIR, File.basename(OPENSSL_URL, '.tar.gz'))
directory openssl_build_dir => [openssl_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{openssl_tarball} -C #{WORKBENCH_DIR}"
end

openssl_static_lib = File.join(openssl_build_dir, 'libssl.a')
file openssl_static_lib => [installed_pkg_config, installed_zlib, openssl_build_dir] do
  sh "cd #{openssl_build_dir} && ./Configure no-shared zlib --prefix='#{DEPENDENCIES_PREFIX}' darwin64-x86_64-cc"
  # OpenSSL needs to be build with at max 1 process
  sh "cd #{openssl_build_dir} && make -j 1"
  # Seems to be a OpenSSL bug in the pkg-config, as libz is required when
  # linking libssl, otherwise Ruby's openssl ext will fail to configure.
  # So add it ourselves.
  openssl_pc_file = File.join(openssl_build_dir, 'openssl.pc')
  content = File.read(openssl_pc_file).sub(/Libs:/, 'Libs: -lz')
  File.open(openssl_pc_file, 'w') { |f| f.write(content) }
end

installed_openssl = File.join(DEPENDENCIES_DESTROOT, 'lib/libssl.a')
file installed_openssl => openssl_static_lib do
  sh "cd #{openssl_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# ncurses
# ------------------------------------------------------------------------------

ncurses_tarball = File.join(DOWNLOAD_DIR, File.basename(NCURSES_URL))
file ncurses_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{NCURSES_URL} -o #{ncurses_tarball}"
end

ncurses_build_dir = File.join(WORKBENCH_DIR, File.basename(NCURSES_URL, '.tar.gz'))
directory ncurses_build_dir => [ncurses_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{ncurses_tarball} -C #{WORKBENCH_DIR}"
  sh "cd #{ncurses_build_dir} && patch -p1 < #{File.join(PATCHES_DIR, 'ncurses.diff')}"
end

ncurses_static_lib = File.join(ncurses_build_dir, 'lib/libncurses.a')
file ncurses_static_lib => [installed_pkg_config, ncurses_build_dir] do
  sh "cd #{ncurses_build_dir} && ./configure --without-shared --enable-getcap  --with-ticlib --with-termlib --disable-leaks --without-debug --enable-pc-files --with-pkg-config --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{ncurses_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_ncurses = File.join(DEPENDENCIES_DESTROOT, 'lib/libncurses.a')
file installed_ncurses => ncurses_static_lib do
  sh "cd #{ncurses_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Readline
# ------------------------------------------------------------------------------

readline_tarball = File.join(DOWNLOAD_DIR, File.basename(READLINE_URL))
file readline_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{READLINE_URL} -o #{readline_tarball}"
end

readline_build_dir = File.join(WORKBENCH_DIR, File.basename(READLINE_URL, '.tar.gz'))
directory readline_build_dir => [readline_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{readline_tarball} -C #{WORKBENCH_DIR}"
end

readline_static_lib = File.join(readline_build_dir, 'libreadline.a')
file readline_static_lib => [installed_pkg_config, installed_ncurses, readline_build_dir] do
  sh "cd #{readline_build_dir} && ./configure --disable-shared --with-curses --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{readline_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_readline = File.join(DEPENDENCIES_DESTROOT, 'lib/libreadline.a')
file installed_readline => readline_static_lib do
  sh "cd #{readline_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# libFFI
# ------------------------------------------------------------------------------

libffi_tarball = File.join(DOWNLOAD_DIR, File.basename(LIBFFI_URL))
file libffi_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{LIBFFI_URL} -o #{libffi_tarball}"
end

libffi_build_dir = File.join(WORKBENCH_DIR, File.basename(LIBFFI_URL, '.tar.gz'))
directory libffi_build_dir => [libffi_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{libffi_tarball} -C #{WORKBENCH_DIR}"
end

# TODO fix for other OS X versions
libffi_static_lib = File.join(libffi_build_dir, 'x86_64-apple-darwin14.0.0/.libs/libffi.a')
file libffi_static_lib => [installed_pkg_config, libffi_build_dir] do
  sh "cd #{libffi_build_dir} && ./configure --disable-shared --enable-static --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{libffi_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_libffi = File.join(DEPENDENCIES_DESTROOT, 'lib/libffi.a')
file installed_libffi => libffi_static_lib do
  sh "cd #{libffi_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Scons
# ------------------------------------------------------------------------------

scons_tarball = File.join(DOWNLOAD_DIR, File.basename(SCONS_URL))
file scons_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{SCONS_URL} -o #{scons_tarball}"
end

scons_build_dir = File.join(WORKBENCH_DIR, File.basename(SCONS_URL, '.tar.gz'))
directory scons_build_dir => [scons_tarball, WORKBENCH_DIR] do
  mkdir_p scons_build_dir
  sh "tar -zxvf #{scons_tarball} -C #{scons_build_dir}"
end

scons_bin = File.expand_path(File.join(scons_build_dir, 'scons.py'))

# ------------------------------------------------------------------------------
# SERF
# ------------------------------------------------------------------------------

serf_tarball = File.join(DOWNLOAD_DIR, File.basename(SERF_URL))
file serf_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{SERF_URL} -o #{serf_tarball}"
end

serf_build_dir = File.join(WORKBENCH_DIR, File.basename(SERF_URL, '.tar.bz2'))
directory serf_build_dir => [serf_tarball, WORKBENCH_DIR] do
  sh "tar -jxvf #{serf_tarball} -C #{WORKBENCH_DIR}"
end

serf_static_lib = File.join(serf_build_dir, 'libserf-1.a')
file serf_static_lib => [installed_pkg_config, installed_openssl, installed_zlib, scons_build_dir, serf_build_dir] do
  sh "cd #{serf_build_dir} && #{scons_bin} PREFIX='#{DEPENDENCIES_PREFIX}' OPENSSL='#{DEPENDENCIES_PREFIX}' ZLIB='#{DEPENDENCIES_PREFIX}'"
  # Seems to be a SERF bug in the pkg-config, as libssl, libcrypto, and libz is
  # required when linking libssl, otherwise Ruby's openssl ext will fail to
  # configure. So add it ourselves.
  serf_pc_file = File.join(serf_build_dir, 'serf-1.pc')
  content = File.read(serf_pc_file).sub('Libs: -L${libdir}', 'Libs: -L${libdir} -lssl -lcrypto -lz')
  File.open(serf_pc_file, 'w') { |f| f.write(content) }
end

installed_serf = File.join(DEPENDENCIES_DESTROOT, 'lib/libserf-1.a')
file installed_serf => serf_static_lib do
  sh "cd #{serf_build_dir} && #{scons_bin} install"
  sh "rm #{File.join(DEPENDENCIES_DESTROOT, 'lib', '*.dylib')}"
end

# ------------------------------------------------------------------------------
# Ruby
# ------------------------------------------------------------------------------

ruby_tarball = File.join(DOWNLOAD_DIR, File.basename(RUBY_URL))
file ruby_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{RUBY_URL} -o #{ruby_tarball}"
end

ruby_build_dir = File.join(WORKBENCH_DIR, File.basename(RUBY_URL, '.tar.gz'))
directory ruby_build_dir => [ruby_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{ruby_tarball} -C #{WORKBENCH_DIR}"
end

ruby_static_lib = File.join(ruby_build_dir, 'libruby-static.a')
#file ruby_static_lib => [installed_pkg_config, installed_ncurses, installed_yaml, installed_zlib, installed_readline, installed_openssl, installed_libffi, ruby_build_dir] do
file ruby_static_lib => [installed_pkg_config, installed_yaml, installed_openssl, ruby_build_dir] do
  sh "cd #{ruby_build_dir} && ./configure --enable-load-relative --disable-shared --with-static-linked-ext --disable-install-doc --with-out-ext=,dbm,gdbm,sdbm,dl/win32,fiddle/win32,tk/tkutil,tk,win32ole,-test-/win32/dln,-test-/win32/fd_setsize,-test-/win32/dln/empty --prefix '#{BUNDLE_PREFIX}'"
  sh "cd #{ruby_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_ruby = File.join(BUNDLE_DESTROOT, 'bin/ruby')
file installed_ruby => ruby_static_lib do
  sh "cd #{ruby_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Gems
# ------------------------------------------------------------------------------

rubygems_update_dir = File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/2.1.0/gems/rubygems-update-2.4.2')
directory rubygems_update_dir => installed_ruby do
  sh "env PATH='#{File.join(BUNDLE_PREFIX, 'bin')}' gem update --system --no-document --env-shebang"
  bin = File.join(BUNDLE_DESTROOT, 'bin/gem')
  lines = File.read(bin).split("\n")
  lines[0] = '#!/usr/bin/env ruby'
  File.open(bin, 'w') { |f| f.write(lines.join("\n")) }
  sh "chmod +x #{bin}"
end

installed_pod_bin = File.join(BUNDLE_DESTROOT, 'bin/pod')
file installed_pod_bin => rubygems_update_dir do
  sh "env PATH='#{File.join(BUNDLE_PREFIX, 'bin')}' gem install cocoapods --version=#{install_cocoapods_version} --no-document --env-shebang"
end

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------

git_tarball = File.join(DOWNLOAD_DIR, File.basename(GIT_URL))
file git_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{GIT_URL} -o #{git_tarball}"
end

git_build_dir = File.join(WORKBENCH_DIR, File.basename(GIT_URL, '.tar.gz'))
directory git_build_dir => [git_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{git_tarball} -C #{WORKBENCH_DIR}"
end

git_bin = File.join(git_build_dir, 'git')
file git_bin => [installed_pkg_config, git_build_dir] do
  sh "cd #{git_build_dir} && ./configure --without-tcltk --prefix '#{BUNDLE_PREFIX}'"
  sh "cd #{git_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_git = File.join(BUNDLE_DESTROOT, 'bin/git')
file installed_git => git_bin do
  sh "cd #{git_build_dir} && env NO_INSTALL_HARDLINKS=1 make install"
  # Even after using the NO_INSTALL_HARDLINKS env var, `bin/git*` is still hardlinked to
  # `libexec/git-core/git*`.
  bin = File.join(BUNDLE_DESTROOT, 'bin')
  Dir.glob(File.join(bin, 'git*')).reject { |f| File.symlink?(f) }.each do |file|
    filename = File.basename(file)
    sh "cd #{bin} && rm #{filename} && ln -s ../libexec/git-core/#{filename} #{filename}"
  end
end

# ------------------------------------------------------------------------------
# Subversion
# ------------------------------------------------------------------------------

svn_tarball = File.join(DOWNLOAD_DIR, File.basename(SVN_URL))
file svn_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{SVN_URL} -o #{svn_tarball}"
end

svn_build_dir = File.join(WORKBENCH_DIR, File.basename(SVN_URL, '.tar.gz'))
directory svn_build_dir => [svn_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{svn_tarball} -C #{WORKBENCH_DIR}"
end

svn_bin = File.join(svn_build_dir, 'subversion/svn/svn')
file svn_bin => [installed_pkg_config, installed_serf, svn_build_dir] do
  sh "cd #{svn_build_dir} && ./configure --disable-shared --enable-all-static --with-serf --without-apxs --without-jikes --without-swig --prefix '#{BUNDLE_PREFIX}'"
  sh "cd #{svn_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_svn = File.join(BUNDLE_DESTROOT, 'bin/svn')
file installed_svn => svn_bin do
  sh "cd #{svn_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Mercurial
# ------------------------------------------------------------------------------

mercurial_tarball = File.join(DOWNLOAD_DIR, File.basename(MERCURIAL_URL))
file mercurial_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{MERCURIAL_URL} -o #{mercurial_tarball}"
end

mercurial_build_dir = File.join(WORKBENCH_DIR, File.basename(MERCURIAL_URL, '.tar.gz'))
directory mercurial_build_dir => [mercurial_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{mercurial_tarball} -C #{WORKBENCH_DIR}"
end

installed_mercurial = File.join(BUNDLE_DESTROOT, 'bin/hg')
file installed_mercurial => mercurial_build_dir do
  sh "cd #{mercurial_build_dir} && make PREFIX='#{BUNDLE_PREFIX}' install-bin"
end

# ------------------------------------------------------------------------------
# Bazaar
# ------------------------------------------------------------------------------

bzr_tarball = File.join(DOWNLOAD_DIR, File.basename(BZR_URL))
file bzr_tarball => DOWNLOAD_DIR do
  sh "curl -sSL #{BZR_URL} -o #{bzr_tarball}"
end

bzr_build_dir = File.join(WORKBENCH_DIR, File.basename(BZR_URL, '.tar.gz'))
directory bzr_build_dir => [bzr_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{bzr_tarball} -C #{WORKBENCH_DIR}"
end

built_bzr_dir = File.join(bzr_build_dir, 'build')
directory built_bzr_dir => [installed_pkg_config, bzr_build_dir] do
  sh "cd #{bzr_build_dir} && python setup.py build"
end

installed_bzr = File.join(BUNDLE_DESTROOT, 'bin/bzr')
file installed_bzr => built_bzr_dir do
  sh "cd #{bzr_build_dir} && python setup.py install --prefix='#{BUNDLE_PREFIX}'"
end

# ------------------------------------------------------------------------------
# Bundle tasks
# ------------------------------------------------------------------------------

installed_env_script = File.join(BUNDLE_DESTROOT, 'bin/bundle-env')
file installed_env_script do
  cp 'bundle-env', installed_env_script
  sh "chmod +x #{installed_env_script}"
end

namespace :bundle do
  task :build_tools => [
    installed_pod_bin,
    installed_ruby,
    installed_git,
    installed_svn,
    installed_bzr,
    installed_mercurial,
    installed_env_script
  ]

  task :remove_unneeded_files => :build_tools do
    remove_if_existant = lambda do |*paths|
      paths.each do |path|
        rm_rf(path) if File.exist?(path)
      end
    end
    puts
    puts "Before clean:"
    sh "du -hs #{BUNDLE_DESTROOT}"
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'bin/svn[a-z]*'))
    remove_if_existant.call *FileList[File.join(BUNDLE_DESTROOT, 'lib/**/*.{,l}a')].exclude(/libruby-static/)
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/man[0-9]'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/.DS_Store'))
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'include/subversion-1')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/2.1.0/cache')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'man')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'share/gitweb')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'share/man')
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/python*/site-packages/bzrlib/tests'))
    # Remove all uncompiled `py` files.
    Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/python*/**/*.pyc')).each do |pyc|
      remove_if_existant.call pyc[0..-2]
    end
    # TODO clean Ruby stdlib
    puts "After clean:"
    sh "du -hs #{BUNDLE_DESTROOT}"
  end

  desc "Verifies that no binaries in the bundle link to incorrect dylibs"
  task :verify_linkage => :remove_unneeded_files do
    skip = %w( .h .rb .py .pyc .tmpl .pem .png .ttf .css .rhtml .js .sample )
    Dir.glob(File.join(BUNDLE_DESTROOT, '**/*')).each do |path|
      next if File.directory?(path)
      next if skip.include?(File.extname(path))
      linkage = `otool -arch x86_64 -L '#{path}'`.strip
      unless linkage.include?('is not an object file')
        linkage = linkage.split("\n")[1..-1]

        puts
        puts "Linkage of `#{path}`:"
        puts linkage

        good = linkage.grep(%r{^\s+(/System/Library/Frameworks/|/usr/lib/)})
        bad = linkage - good
        unless bad.empty?
          puts
          puts "[!] Bad linkage found in `#{path}`:"
          puts bad
          exit 1
        end
      end
    end
  end

  desc "Test bundle"
  task :test => :build_tools do
    test_dir = 'tmp'
    rm_rf test_dir
    mkdir_p test_dir
    cp 'Podfile', test_dir
    sh "cd #{test_dir} && #{File.expand_path(installed_env_script)} pod install --no-integrate --verbose"
  end

  desc "Build complete dist bundle"
  task :build => [:build_tools, :remove_unneeded_files, :verify_linkage, :test] do
    puts
    puts "Finished building bundle in #{Time.now - $build_started_at} seconds"
    puts
  end

  namespace :clean do
    task :build do
      rm_rf WORKBENCH_DIR
    end

    task :downloads do
      rm_rf DOWNLOAD_DIR
    end

    task :destroot do
      rm_rf DESTROOT
    end

    desc "Clean build and destroot artefacts"
    task :artefacts => [:build, :destroot]

    desc "Clean all artefacts, including downloads"
    task :all => [:artefacts, :downloads]
  end
end

# ------------------------------------------------------------------------------
# CocoaPods.app
# ------------------------------------------------------------------------------

XCODEBUILD_COMMAND = "cd app && xcodebuild -workspace CocoaPods.xcworkspace -scheme CocoaPods -configuration Release"

namespace :app do
  desc 'Updates the Info.plist of the application to reflect the CocoaPods version'
  task :update_version do
    info_plist = File.expand_path('app/CocoaPods/Info.plist')
    sh "/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString #{install_cocoapods_version}' '#{info_plist}'"
    build = `/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' '#{info_plist}'`.strip.to_i
    sh "/usr/libexec/PlistBuddy -c 'Set :CFBundleVersion #{build+1}' '#{info_plist}'"
  end

  desc 'Build release version of application'
  task :build => ['bundle:build', :update_version] do
    sh "#{XCODEBUILD_COMMAND} MACOSX_DEPLOYMENT_TARGET=#{DEPLOYMENT_TARGET} build"
  end

  desc "Clean"
  task :clean do
    sh "#{XCODEBUILD_COMMAND} clean"
  end
end

# ------------------------------------------------------------------------------
# Release tasks
# ------------------------------------------------------------------------------

namespace :release do
  task :clean => ['bundle:clean:all', 'app:clean']

  desc "Perform a full build of the bundle and app"
  task :build => ['bundle:build', 'app:build', PKG_DIR] do
    output = `#{XCODEBUILD_COMMAND} -showBuildSettings | grep -w BUILT_PRODUCTS_DIR`.strip
    build_dir = output.split('= ').last
    tarball = File.expand_path(File.join(PKG_DIR, "CocoaPods.app-#{install_cocoapods_version}.tar.xz"))
    sh "cd '#{build_dir}' && tar cfJ '#{tarball}' CocoaPods.app"

    puts
    puts "Finished building release in #{Time.now - $build_started_at} seconds"
    puts
  end

  desc "Create a clean build"
  task :cleanbuild => [:clean, :build]
end

desc "Create a clean release build for distribution"
task :release do
  unless File.basename(SDKROOT) == DEPLOYMENT_TARGET_SDK
    puts "[!] Unable to find the SDK for the deployment target `#{DEPLOYMENT_TARGET}`, which is " \
         "required to create a distribution release."
    exit 1
  end
  Rake::Task['release:cleanbuild'].invoke
end
