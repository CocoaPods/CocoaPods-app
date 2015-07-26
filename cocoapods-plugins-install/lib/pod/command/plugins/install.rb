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
            gem! "install", "--no-document", "--env-shebang", "--file", temp_gemfile
            record_plugin_installation
          end
        end

        private

        def temp_gemfile
          unless @temp_gemfile
            require 'cocoapods/gem_version'
            require 'tempfile'
            Tempfile.open("cocoapods-plugins-install-#{@name}") do |gemfile|
              gemfile.puts "source 'https://rubygems.org'"
              gemfile.puts "gem 'cocoapods', '#{Pod::VERSION}'"
              unless dev_tools_installed?
                available_gems_that_require_dev_tools.each do |gem|
                  gemfile.puts "gem '#{gem.name}', '#{gem.version}'"
                end
              end
              gemfile.puts "gem '#{@name}'"
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

        # http://stackoverflow.com/a/15371967/95397
        def dev_tools_installed?
          osx_version = `/usr/bin/sw_vers -productVersion`.strip.split('.').first(2).join('.')
          case osx_version
          when '10.8'
            system('/usr/sbin/pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI > /dev/null 2>&1')
          when '10.9', '10.10', '10.11'
            system('/usr/sbin/pkgutil --pkg-info=com.apple.pkg.CLTools_Executables > /dev/null 2>&1')
          else
            $stderr.puts "[!] Unable to determine if dev tools are installed, assuming they are."
            true
          end
        end

        def available_gems_that_require_dev_tools
          Gem::Specification.reject { |spec| spec.extensions.empty? }
                            .sort_by { |gem| [gem.name, gem.version] }
                            .reverse
                            .inject({}) { |gems, gem| gems[gem.name] ||= gem; gems }
                            .values
        end
      end
    end
  end
end
