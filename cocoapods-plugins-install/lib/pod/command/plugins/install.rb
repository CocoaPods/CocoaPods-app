require 'pod/command/plugins'
require 'cocoapods/executable'
require 'rubygems/defaults'

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
          @name = argv.shift_argument
          super
        end

        def validate!
          super
          help! "A CocoaPods plugin name is required." unless @name
          unless File.writable?(Gem.default_dir)
            raise Informative, 'You do not have permissions to install a ' \
                               'plugin. Perhaps try prefixing this command ' \
                               'with sudo.'
          end
        end

        extend Executable
        executable :gem

        def run
          gem! "install", "--file", temp_gemfile
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
      end
    end
  end
end

