DOWNLOAD_DIR = 'downloads'
WORKBENCH_DIR = 'workbench'
DESTROOT = 'destroot'

PREFIX = File.expand_path(DESTROOT)

LIBYAML_VERSION = '0.1.6'
LIBYAML_URL = "http://pyyaml.org/download/libyaml/yaml-#{LIBYAML_VERSION}.tar.gz"

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

yaml_config_file = File.join(yaml_build_dir, 'config.status')
file yaml_config_file => yaml_build_dir do
  sh "cd #{yaml_build_dir} && ./configure --disable-shared --enable-static --prefix '#{PREFIX}'"
end

yaml_static_lib = File.join(yaml_build_dir, 'src/.libs/libyaml.a')
file yaml_static_lib => yaml_config_file do
  sh "cd #{yaml_build_dir} && make"
end

installed_yaml = File.join(DESTROOT, 'lib/libyaml.a')
file installed_yaml => yaml_static_lib do
  sh "cd #{yaml_build_dir} && make install"
end

task :build => [installed_yaml]

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

  task :all => [:build, :destroot, :downloads]
end

task :clean => ['clean:build', 'clean:destroot']

#namespace :build do
  #task :ruby do
  #end
#end
