MAKE_CONCURRENCY = `sysctl hw.physicalcpu`.strip.match(/\d+$/)[0].to_i + 1

DOWNLOAD_DIR = 'downloads'
WORKBENCH_DIR = 'workbench'
DESTROOT = 'destroot'

PREFIX = File.expand_path(DESTROOT)

LIBYAML_VERSION = '0.1.6'
LIBYAML_URL = "http://pyyaml.org/download/libyaml/yaml-#{LIBYAML_VERSION}.tar.gz"

ZLIB_VERSION = '1.2.8'
ZLIB_URL = "http://zlib.net/zlib-#{ZLIB_VERSION}.tar.gz"

OPENSSL_VERSION = '1.0.1j'
OPENSSL_URL = "https://www.openssl.org/source/openssl-#{OPENSSL_VERSION}.tar.gz"

directory DOWNLOAD_DIR
directory WORKBENCH_DIR
directory DESTROOT

# ------------------------------------------------------------------------------
# YAML
# ------------------------------------------------------------------------------

yaml_tarball = File.join(DOWNLOAD_DIR, File.basename(LIBYAML_URL))
file yaml_tarball => DOWNLOAD_DIR do
  sh "curl #{LIBYAML_URL} -o #{yaml_tarball}"
end

yaml_build_dir = File.join(WORKBENCH_DIR, File.basename(LIBYAML_URL, '.tar.gz'))
directory yaml_build_dir => [yaml_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{yaml_tarball} -C #{WORKBENCH_DIR}"
end

yaml_static_lib = File.join(yaml_build_dir, 'src/.libs/libyaml.a')
file yaml_static_lib => yaml_build_dir do
  sh "cd #{yaml_build_dir} && ./configure --disable-shared --prefix '#{PREFIX}'"
  sh "cd #{yaml_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_yaml = File.join(DESTROOT, 'lib/libyaml.a')
file installed_yaml => yaml_static_lib do
  sh "cd #{yaml_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# ZLIB
# ------------------------------------------------------------------------------

zlib_tarball = File.join(DOWNLOAD_DIR, File.basename(ZLIB_URL))
file zlib_tarball => DOWNLOAD_DIR do
  sh "curl #{ZLIB_URL} -o #{zlib_tarball}"
end

zlib_build_dir = File.join(WORKBENCH_DIR, File.basename(ZLIB_URL, '.tar.gz'))
directory zlib_build_dir => [zlib_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{zlib_tarball} -C #{WORKBENCH_DIR}"
end

zlib_static_lib = File.join(zlib_build_dir, 'libz.a')
file zlib_static_lib => zlib_build_dir do
  sh "cd #{zlib_build_dir} && ./configure --static --prefix '#{PREFIX}'"
  sh "cd #{zlib_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_zlib = File.join(DESTROOT, 'lib/libz.a')
file installed_zlib => zlib_static_lib do
  sh "cd #{zlib_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# OpenSSL
# ------------------------------------------------------------------------------

openssl_tarball = File.join(DOWNLOAD_DIR, File.basename(OPENSSL_URL))
file openssl_tarball => DOWNLOAD_DIR do
  sh "curl #{OPENSSL_URL} -o #{openssl_tarball}"
end

openssl_build_dir = File.join(WORKBENCH_DIR, File.basename(OPENSSL_URL, '.tar.gz'))
directory openssl_build_dir => [openssl_tarball, WORKBENCH_DIR] do
  sh "tar -zxvf #{openssl_tarball} -C #{WORKBENCH_DIR}"
end

openssl_static_lib = File.join(openssl_build_dir, 'libssl.a')
file openssl_static_lib => [installed_zlib, openssl_build_dir] do
  sh "cd #{openssl_build_dir} && ./Configure no-shared zlib --prefix='#{PREFIX}' darwin64-x86_64-cc"
  sh "cd #{zlib_build_dir} && make -j #{MAKE_CONCURRENCY}"
end

installed_openssl = File.join(DESTROOT, 'lib/libssl.a')
file installed_openssl => openssl_static_lib do
  sh "cd #{openssl_build_dir} && make install"
end

# ------------------------------------------------------------------------------
# Tasks
# ------------------------------------------------------------------------------

desc "Build all dependencies"
task :build => [installed_yaml, installed_zlib, installed_openssl] do
  sh "tree #{DESTROOT}/lib"
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
