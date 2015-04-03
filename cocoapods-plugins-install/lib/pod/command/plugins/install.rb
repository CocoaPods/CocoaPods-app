require 'pod/command/plugins'
require 'cocoapods/executable'

module Pod
  class Command
    class Plugins
      class Install < Plugins
        self.summary = "Install a CocoaPods plugin"

        self.description = <<-DESC
          Install a CocoaPods plugin into the current CocoaPods.app bundle.
        DESC

        self.arguments = [CLAide::Argument.new('NAME', true)]

        def initialize(argv)
          @name = argv.shift_argument.strip
          super
        end

        def validate!
          super
          help! "A CocoaPods plugin name is required." unless @name

          require 'rubygems/defaults'
          unless File.writable?(Gem.default_dir)
            raise Informative, 'You do not have permissions to install a ' \
                               'plugin. Perhaps try prefixing this command ' \
                               'with sudo.'
          end
        end

        extend Executable
        executable :gem

        def run
          UI.section "Installing plugin: #{@name}" do
            gem! "install", "--file", temp_gemfile
            record_plugin_installation
          end
        end

        private

        def temp_gemfile
          unless @temp_gemfile
            require 'cocoapods/gem_version'
            require 'tempfile'
            Tempfile.open("cocoapods-plugins-install-#{@name}") do |gemfile|
              gemfile.write <<-GEMFILE
                source 'https://rubygems.org'
                gem 'cocoapods', '#{Pod::VERSION}'
                gem '#{@name}'
              GEMFILE
              @temp_gemfile = gemfile.path
            end
          end
          @temp_gemfile
        end

        def record_plugin_installation
          require 'rbconfig'
          require 'yaml'
          share_dir = RbConfig::CONFIG['datadir']
          path = File.join(share_dir, 'cocoapods-plugins.yml')
          manifest = File.exist?(path) ? YAML.load_file(path) : []
          manifest << @name
          manifest.uniq!
          manifest.sort!
          File.write(path, manifest.to_yaml)
        end
      end
    end
  end
end

