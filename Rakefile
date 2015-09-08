RELEASE_PLATFORM = '10.11'

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

ORIGINAL_PATH = ENV['PATH']
ENV['PATH'] = "#{File.join(DEPENDENCIES_PREFIX, 'bin')}:/usr/bin:/bin"
ENV['CC'] = '/usr/bin/clang'
ENV['CXX'] = '/usr/bin/clang++'
ENV['CFLAGS'] = "-mmacosx-version-min=#{DEPLOYMENT_TARGET} -isysroot #{SDKROOT}"
ENV['CPPFLAGS'] = "-I#{File.join(DEPENDENCIES_PREFIX, 'include')}"
ENV['LDFLAGS'] = "-L#{File.join(DEPENDENCIES_PREFIX, 'lib')}"

# If we don't create this dir and set the env var, the ncurses configure
# script will simply decide that we don't want any .pc files.
PKG_CONFIG_LIBDIR = File.join(DEPENDENCIES_PREFIX, 'lib/pkgconfig')
ENV['PKG_CONFIG_LIBDIR'] = PKG_CONFIG_LIBDIR

# Defaults to the latest available version or the VERSION env variable.
def install_cocoapods_version
  return @install_cocoapods_version if @install_cocoapods_version
  return @install_cocoapods_version = ENV['VERSION'] if ENV['VERSION']

  sh "PATH=#{ORIGINAL_PATH} pod repo update master"
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

OPENSSL_VERSION = '1.0.2d'
OPENSSL_URL = "https://www.openssl.org/source/openssl-#{OPENSSL_VERSION}.tar.gz"

NCURSES_VERSION = '5.9'
NCURSES_URL = "http://ftpmirror.gnu.org/ncurses/ncurses-#{NCURSES_VERSION}.tar.gz"

READLINE_VERSION = '6.3'
READLINE_URL = "http://ftpmirror.gnu.org/readline/readline-#{READLINE_VERSION}.tar.gz"

RUBY__VERSION = '2.2.2'
RUBY_URL = "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-#{RUBY__VERSION}.tar.gz"

RUBYGEMS_VERSION = '2.4.8'
RUBYGEMS_URL = "https://rubygems.org/downloads/rubygems-update-#{RUBYGEMS_VERSION}.gem"

CURL_VERSION = '7.41.0'
CURL_URL = "http://curl.haxx.se/download/curl-#{CURL_VERSION}.tar.gz"

GIT_VERSION = '2.4.3'
GIT_URL = "https://www.kernel.org/pub/software/scm/git/git-#{GIT_VERSION}.tar.gz"

SCONS_VERSION = '2.3.4'
SCONS_URL = "http://prdownloads.sourceforge.net/scons/scons-local-#{SCONS_VERSION}.tar.gz"

SERF_VERSION = '1.3.8'
SERF_URL = "http://serf.googlecode.com/svn/src_releases/serf-#{SERF_VERSION}.tar.bz2"

SVN_VERSION = '1.8.13'
SVN_URL = "https://archive.apache.org/dist/subversion/subversion-#{SVN_VERSION}.tar.gz"

BZR_VERSION = '2.6.0'
BZR_URL = "https://launchpad.net/bzr/2.6/2.6.0/+download/bzr-#{BZR_VERSION}.tar.gz"

MERCURIAL_VERSION = '3.3.3'
MERCURIAL_URL = "http://mercurial.selenic.com/release/mercurial-#{MERCURIAL_VERSION}.tar.gz"

# ------------------------------------------------------------------------------
# pkg-config
# ------------------------------------------------------------------------------

pkg_config_tarball = File.join(DOWNLOAD_DIR, File.basename(PKG_CONFIG_URL))
file pkg_config_tarball => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{PKG_CONFIG_URL} -o #{pkg_config_tarball}"
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
  sh "/usr/bin/curl -sSL #{LIBYAML_URL} -o #{yaml_tarball}"
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
  sh "/usr/bin/curl -sSL #{ZLIB_URL} -o #{zlib_tarball}"
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
  sh "/usr/bin/curl -sSL #{OPENSSL_URL} -o #{openssl_tarball}"
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
  %w( libcrypto.pc libssl.pc ).each do |pc_filename|
    pc_file = File.join(openssl_build_dir, pc_filename)
    original_content = File.read(pc_file)
    content = original_content.sub(/Libs:/, 'Libs: -lz')
    if original_content == content
      raise "[!] Did not patch anything in: #{pc_file}"
    end
    File.open(pc_file, 'w') { |f| f.write(content) }
  end
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
  sh "/usr/bin/curl -sSL #{NCURSES_URL} -o #{ncurses_tarball}"
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
  sh "/usr/bin/curl -sSL #{READLINE_URL} -o #{readline_tarball}"
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
# Scons
# ------------------------------------------------------------------------------

scons_tarball = File.join(DOWNLOAD_DIR, File.basename(SCONS_URL))
file scons_tarball => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{SCONS_URL} -o #{scons_tarball}"
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
  sh "/usr/bin/curl -sSL #{SERF_URL} -o #{serf_tarball}"
end

serf_build_dir = File.join(WORKBENCH_DIR, File.basename(SERF_URL, '.tar.bz2'))
directory serf_build_dir => [serf_tarball, WORKBENCH_DIR] do
  sh "tar -jxvf #{serf_tarball} -C #{WORKBENCH_DIR}"
end

serf_static_lib = File.join(serf_build_dir, 'libserf-1.a')
file serf_static_lib => [installed_pkg_config, installed_openssl, installed_zlib, scons_build_dir, serf_build_dir] do
  sh "cd #{serf_build_dir} && #{scons_bin} PREFIX='#{DEPENDENCIES_PREFIX}' OPENSSL='#{DEPENDENCIES_PREFIX}' ZLIB='#{DEPENDENCIES_PREFIX}'"
  # Seems to be a SERF bug in the pkg-config, as libssl, libcrypto, and libz is
  # required when linking libssl, otherwise svn will fail to build with our
  # OpenSSl. So add it ourselves.
  serf_pc_file = File.join(serf_build_dir, 'serf-1.pc')
  original_content = File.read(serf_pc_file)
  content = original_content.sub('Libs: -L${libdir}', 'Libs: -L${libdir} -lssl -lcrypto -lz')
  if original_content == content
    raise "[!] Did not patch anything in: #{serf_pc_file}"
  end
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
  sh "/usr/bin/curl -sSL #{RUBY_URL} -o #{ruby_tarball}"
end

ruby_build_dir = File.join(WORKBENCH_DIR, File.basename(RUBY_URL, '.tar.gz'))
directory ruby_build_dir => [ruby_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{ruby_tarball} -C #{WORKBENCH_DIR}"
end

ruby_static_lib = File.join(ruby_build_dir, 'libruby-static.a')
file ruby_static_lib => [installed_pkg_config, installed_yaml, installed_openssl, ruby_build_dir] do
  sh "cd #{ruby_build_dir} && ./configure --enable-load-relative --disable-shared --with-static-linked-ext --disable-install-doc --with-out-ext=,dbm,gdbm,sdbm,dl/win32,fiddle/win32,tk/tkutil,tk,win32ole,-test-/win32/dln,-test-/win32/fd_setsize,-test-/win32/dln/empty --prefix '#{BUNDLE_PREFIX}'"
  sh "cd #{ruby_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_ruby = File.join(BUNDLE_DESTROOT, 'bin/ruby')
file installed_ruby => ruby_static_lib do
  sh "cd #{ruby_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# bundle-env
# ------------------------------------------------------------------------------

installed_env_script = File.join(BUNDLE_DESTROOT, 'bin/bundle-env')
file installed_env_script do
  cp 'bundle-env', installed_env_script
  sh "chmod +x #{installed_env_script}"
end

# ------------------------------------------------------------------------------
# Gems
# ------------------------------------------------------------------------------

gem_home = File.join(BUNDLE_DESTROOT, 'lib/ruby/gems', RUBY__VERSION.sub(/\d+$/, '0'))

rubygems_gem = File.join(DOWNLOAD_DIR, File.basename(RUBYGEMS_URL))
file rubygems_gem => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{RUBYGEMS_URL} -o #{rubygems_gem}"
end

rubygems_update_dir = File.join(gem_home, 'gems', File.basename(RUBYGEMS_URL, '.gem'))
directory rubygems_update_dir => [installed_ruby, installed_env_script, rubygems_gem] do
  sh "'#{File.join(BUNDLE_PREFIX, 'bin/bundle-env')}' gem install #{rubygems_gem} --no-document --env-shebang"
  sh "'#{File.join(BUNDLE_PREFIX, 'bin/bundle-env')}' update_rubygems"
  bin = File.join(BUNDLE_DESTROOT, 'bin/gem')
  lines = File.read(bin).split("\n")
  lines[0] = '#!/usr/bin/env ruby'
  File.open(bin, 'w') { |f| f.write(lines.join("\n")) }
  sh "chmod +x #{bin}"
end

def install_gem(name, version = nil)
  sh "'#{File.join(BUNDLE_PREFIX, 'bin', 'bundle-env')}' gem install #{name} #{"--version=#{version}" if version} --no-document --env-shebang"
end

installed_pod_bin = File.join(BUNDLE_DESTROOT, 'bin/pod')
file installed_pod_bin => rubygems_update_dir do
  install_gem 'cocoapods', install_cocoapods_version
end

# ------------------------------------------------------------------------------
# pod plugins install
# ------------------------------------------------------------------------------

plugin = 'cocoapods-plugins-install'
$:.unshift "#{plugin}/lib"
require "#{plugin}/gem_version"
plugin_with_version = "#{plugin}-#{CocoapodsPluginsInstall::VERSION}"

installed_cocoapods_plugins_install = File.join(gem_home, 'gems', plugin_with_version)
directory installed_cocoapods_plugins_install => installed_pod_bin do
  Dir.chdir(plugin) do
    sh "gem build #{plugin}.gemspec"
  end
  install_gem "#{plugin}/#{plugin_with_version}.gem"
end

# ------------------------------------------------------------------------------
# Third-party gems
# ------------------------------------------------------------------------------

# Note, this assumes its being build on the latest OS X version.
installed_osx_gems = []
Dir.glob('/System/Library/Frameworks/Ruby.framework/Versions/[0-9]*/usr/lib/ruby/gems/*/specifications/*.gemspec').each do |gemspec|
  # We have to make some file that does not contain any version information, otherwise we'd first have to query rubygems
  # for the available versions, which is going to take a long time.
  installed_gem = File.join(gem_home, 'specifications', "#{File.basename(gemspec, '.gemspec').split('-')[0..-2].join('-')}.CocoaPods-app.installed")
  installed_osx_gems << installed_gem
  file installed_gem => rubygems_update_dir do
    require 'rubygems/specification'
    gem = Gem::Specification.load(gemspec)
    # First install the exact same version that Apple included in OS X.
    case gem.name
    when 'libxml-ruby'
      # libxml-ruby-2.6.0 has an extconf.rb that depends on old behavior where `RbConfig` was available as `Config`.
      install_gem(File.join(PATCHES_DIR, "#{File.basename(gemspec, '.gemspec')}.gem"))
    when 'sqlite3'
      # sqlite3-1.3.7 depends on BigDecimal header from before BigDecimal was made into a gem. I doubt anybody really
      # uses sqlite for CocoaPods dependencies anyways, so just skip this old version.
    else
      install_gem(gem.name, gem.version)
    end
    # Now install the latest version of the gem.
    install_gem(gem.name)
    # Create our nonsense file that's only used to track whether or not the gems were installed.
    touch installed_gem
  end
end

# ------------------------------------------------------------------------------
# cURL
# ------------------------------------------------------------------------------

curl_tarball = File.join(DOWNLOAD_DIR, File.basename(CURL_URL))
file curl_tarball => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{CURL_URL} -o #{curl_tarball}"
end

curl_build_dir = File.join(WORKBENCH_DIR, File.basename(CURL_URL, '.tar.gz'))
directory curl_build_dir => [curl_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{curl_tarball} -C #{WORKBENCH_DIR}"
end

libcurl = File.join(curl_build_dir, 'lib/.libs/libcurl.a')
file libcurl => [installed_pkg_config, installed_openssl, installed_zlib, curl_build_dir] do
  sh "cd #{curl_build_dir} && ./configure --disable-shared --enable-static --prefix '#{DEPENDENCIES_PREFIX}'"
  sh "cd #{curl_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_libcurl = File.join(DEPENDENCIES_DESTROOT, 'lib/libcurl.a')
file installed_libcurl => libcurl do
  sh "cd #{curl_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------

git_tarball = File.join(DOWNLOAD_DIR, File.basename(GIT_URL))
file git_tarball => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{GIT_URL} -o #{git_tarball}"
end

git_build_dir = File.join(WORKBENCH_DIR, File.basename(GIT_URL, '.tar.gz'))
directory git_build_dir => [git_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{git_tarball} -C #{WORKBENCH_DIR}"
end

git_bin = File.join(git_build_dir, 'git')
file git_bin => [installed_pkg_config, installed_libcurl, git_build_dir] do
  sh "cd #{git_build_dir} && ./configure --without-tcltk --prefix '#{BUNDLE_PREFIX}' LDFLAGS='-L \"#{DEPENDENCIES_PREFIX}/lib\" -lssl -lcrypto -lz -lcurl -lldap' CPPFLAGS='-I\"#{DEPENDENCIES_PREFIX}/include\"'"
  sh "cd #{git_build_dir} && make -j #{MAKE_CONCURRENCY} V=1"
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
  sh "/usr/bin/curl -sSL #{SVN_URL} -o #{svn_tarball}"
end

svn_build_dir = File.join(WORKBENCH_DIR, File.basename(SVN_URL, '.tar.gz'))
directory svn_build_dir => [svn_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{svn_tarball} -C #{WORKBENCH_DIR}"
end

svn_bin = File.join(svn_build_dir, 'subversion/svn/svn')
file svn_bin => [installed_pkg_config, installed_serf, installed_libcurl, svn_build_dir] do
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
  sh "/usr/bin/curl -sSL #{MERCURIAL_URL} -o #{mercurial_tarball}"
end

mercurial_build_dir = File.join(WORKBENCH_DIR, File.basename(MERCURIAL_URL, '.tar.gz'))
directory mercurial_build_dir => [mercurial_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{mercurial_tarball} -C #{WORKBENCH_DIR}"
end

installed_mercurial = File.join(BUNDLE_DESTROOT, 'bin/hg')
file installed_mercurial => [installed_libcurl, mercurial_build_dir] do
  sh "cd #{mercurial_build_dir} && make PREFIX='#{BUNDLE_PREFIX}' install-bin"
end

# ------------------------------------------------------------------------------
# Bazaar
# ------------------------------------------------------------------------------

bzr_tarball = File.join(DOWNLOAD_DIR, File.basename(BZR_URL))
file bzr_tarball => DOWNLOAD_DIR do
  sh "/usr/bin/curl -sSL #{BZR_URL} -o #{bzr_tarball}"
end

bzr_build_dir = File.join(WORKBENCH_DIR, File.basename(BZR_URL, '.tar.gz'))
directory bzr_build_dir => [bzr_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{bzr_tarball} -C #{WORKBENCH_DIR}"
end

built_bzr_dir = File.join(bzr_build_dir, 'build')
directory built_bzr_dir => [installed_pkg_config, installed_libcurl, bzr_build_dir] do
  sh "cd #{bzr_build_dir} && python setup.py build"
end

installed_bzr = File.join(BUNDLE_DESTROOT, 'bin/bzr')
file installed_bzr => built_bzr_dir do
  sh "cd #{bzr_build_dir} && python setup.py install --prefix='#{BUNDLE_PREFIX}'"
end

# ------------------------------------------------------------------------------
# Root Certificates
# ------------------------------------------------------------------------------

installed_cacert = File.join(BUNDLE_DESTROOT, 'share/cacert.pem')
file installed_cacert do
  sh "security find-certificate -a -p /Library/Keychains/System.keychain > '#{installed_cacert}'"
  sh "security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > '#{installed_cacert}'"
end

# ------------------------------------------------------------------------------
# Bundle tasks
# ------------------------------------------------------------------------------

namespace :bundle do
  task :build_tools => [
    installed_ruby,
    installed_pod_bin,
    installed_cocoapods_plugins_install,
    installed_git,
    installed_svn,
    installed_bzr,
    installed_mercurial,
    installed_env_script,
    installed_cacert,
  ].concat(installed_osx_gems)

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
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/**/*.o'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/*/cache'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/man[0-9]'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/.DS_Store'))
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'include/subversion-1')
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
      next if File.basename(path) == 'libruby-static.a'
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
  task :build => [:build_tools, :remove_unneeded_files] do
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
    info_plist = File.expand_path('app/CocoaPods/Supporting Files/Info.plist')
    sh "/usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString #{install_cocoapods_version}' '#{info_plist}'"
    sh "/usr/libexec/PlistBuddy -c 'Set :CFBundleVersion #{install_cocoapods_version}' '#{info_plist}'"
  end

  desc 'Build release version of application'
  task :build => ['bundle:build', :update_version] do
    sh "#{XCODEBUILD_COMMAND} MACOSX_DEPLOYMENT_TARGET=#{DEPLOYMENT_TARGET} SDKROOT='#{SDKROOT}' build"
  end

  desc "Clean"
  task :clean do
    sh "#{XCODEBUILD_COMMAND} clean"
  end
end

# ------------------------------------------------------------------------------
# Release tasks
# ------------------------------------------------------------------------------

def github_access_token
  File.read('.github_access_token').strip rescue nil
end

namespace :release do
  task :clean => ['bundle:clean:all', 'app:clean']

  desc "Perform a full build of the bundle and app"
  task :build => ['bundle:build', 'bundle:verify_linkage', 'bundle:test', 'app:build', PKG_DIR] do
    output = `#{XCODEBUILD_COMMAND} -showBuildSettings | grep -w BUILT_PRODUCTS_DIR`.strip
    build_dir = output.split('= ').last
    #tarball = File.expand_path(File.join(PKG_DIR, "CocoaPods.app-#{install_cocoapods_version}.tar.xz"))
    #sh "cd '#{build_dir}' && tar cfJ '#{tarball}' CocoaPods.app"
    tarball = File.expand_path(File.join(PKG_DIR, "CocoaPods.app-#{install_cocoapods_version}.tar.bz2"))
    sh "cd '#{build_dir}' && tar cfj '#{tarball}' CocoaPods.app"

    puts
    puts "Finished building release in #{Time.now - $build_started_at} seconds"
    puts
  end

  desc "Create a clean build"
  task :cleanbuild => [:clean, :build]

  desc "Upload release"
  task :upload => [] do
    tarball = File.expand_path(File.join(PKG_DIR, "CocoaPods.app-#{install_cocoapods_version}.tar.bz2"))
    sha = `shasum -a 256 -b '#{tarball}'`.split(' ').first

    require 'net/http'
    require 'json'
    require 'rest'

    github_headers = {
      'Content-Type' => 'application/json',
      'User-Agent' => 'runscope/0.1,segiddins',
      'Accept' => 'application/json',
    }

    response = REST.post("https://api.github.com/repos/CocoaPods/CocoaPods-app/releases?access_token=#{github_access_token}",
                         {tag_name: install_cocoapods_version, name: install_cocoapods_version}.to_json,
                         github_headers)

    tarball_name = File.basename(tarball)

    upload_url = JSON.load(response.body)['upload_url'].gsub('{?name}', "?name=#{tarball_name}&Content-Type=application/x-tar&access_token=#{github_access_token}")
    response = REST.post(upload_url, File.read(tarball, :mode => 'rb'), github_headers)
    tarball_download_url = JSON.load(response.body)['browser_download_url']

    puts
    puts "Make a PR to https://github.com/CocoaPods/CocoaPods-app/blob/master/homebrew-cask " \
         "updating the version to #{install_cocoapods_version} and the sha to #{sha}"
    puts
  end
end

desc "Create a clean release build for distribution"
task :release do
  unless `sw_vers -productVersion`.strip.split('.').first(2).join('.') == RELEASE_PLATFORM
    puts "[!] A release build must be performed on the latest OS X version to ensure all the gems that Apple includes " \
         "in its OS will be bundled."
    exit 1
  end
  unless File.basename(SDKROOT) == DEPLOYMENT_TARGET_SDK
    puts "[!] Unable to find the SDK for the deployment target `#{DEPLOYMENT_TARGET}`, which is required to create a " \
         "distribution release."
    exit 1
  end
  unless github_access_token
    puts "[!] You have not provided a github access token via `.github_access_token`, " \
         'so a GitHub release cannot be made.'
    exit 1
  end
  Rake::Task['release:cleanbuild'].invoke
  Rake::Task['release:upload'].invoke
end
