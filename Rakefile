# OpenSSL fails if we set this make configuration through MAKEFLAGS, so we pass
# it to each make invocation seperately.
MAKE_CONCURRENCY = `sysctl hw.physicalcpu`.strip.match(/\d+$/)[0].to_i + 1

DOWNLOAD_DIR = 'downloads'
WORKBENCH_DIR = 'workbench'
DESTROOT = 'destroot'
BUNDLE_DESTROOT = File.join(DESTROOT, 'bundle')
DEPENDENCIES_DESTROOT = File.join(DESTROOT, 'dependencies')

PATCHES_DIR = File.expand_path('patches')
BUNDLE_PREFIX = File.expand_path(BUNDLE_DESTROOT)
DEPENDENCIES_PREFIX = File.expand_path(DEPENDENCIES_DESTROOT)

directory DOWNLOAD_DIR
directory WORKBENCH_DIR
directory DEPENDENCIES_DESTROOT

ENV['PATH'] = "#{File.join(DEPENDENCIES_PREFIX, 'bin')}:#{ENV['PATH']}"
ENV['CFLAGS'] = "-I#{File.join(DEPENDENCIES_PREFIX, 'include')}"
ENV['LDFLAGS'] = "-L#{File.join(DEPENDENCIES_PREFIX, 'lib')}"

# If we don't create this dir and set the env var, the ncurses configure
# script will simply decide that we don't want any .pc files.
PKG_CONFIG_LIBDIR = File.join(DEPENDENCIES_PREFIX, 'lib/pkgconfig')
ENV['PKG_CONFIG_LIBDIR'] = PKG_CONFIG_LIBDIR
directory PKG_CONFIG_LIBDIR

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
file installed_pkg_config => [pkg_config_bin, PKG_CONFIG_LIBDIR] do
  sh "cd #{pkg_config_build_dir} && make install"
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
  #sh "cd #{openssl_build_dir} && make -j #{MAKE_CONCURRENCY}"
  sh "cd #{openssl_build_dir} && make"
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
  sh "cd #{ruby_build_dir} && ./configure --enable-load-relative --disable-shared --with-static-linked-ext --with-out-ext=-test-,dbm,gdbm,sdbm,tk --disable-install-doc --prefix '#{BUNDLE_PREFIX}'"
  sh "cd #{ruby_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_ruby = File.join(BUNDLE_DESTROOT, 'bin/ruby')
file installed_ruby => ruby_static_lib do
  sh "cd #{ruby_build_dir} && make install"
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
  sh "cd #{git_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Tasks
# ------------------------------------------------------------------------------

desc "Build all dependencies and Ruby"
task :build => installed_ruby do
  links = `otool -L #{File.join(BUNDLE_DESTROOT, 'bin/ruby')}`.strip.split("\n")[1..-1]

  puts
  puts "Ruby links against:"
  puts links

  good = links.grep(%r{^\s+(/System/Library/Frameworks/CoreFoundation|/usr/lib/)})
  bad = links - good
  unless bad.empty?
    puts "Ruby is linking against these libs in unexpected locations:"
    puts bad
    exit 1
  end
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

  desc "Clean all artefacts, including downloads"
  task :all => [:build, :destroot, :downloads]
end

desc "Clean all build artefacts"
task :clean => ['clean:build', 'clean:destroot']

#namespace :build do
  #task :ruby do
  #end
#end
