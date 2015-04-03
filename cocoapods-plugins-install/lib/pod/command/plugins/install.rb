require 'pod/command/plugins'

module Pod
  class Command
    class Plugins
      class Install < Plugins
        self.summary = "Install a CocoaPods plugin"

        self.description = <<-DESC
          Install a CocoaPods plugin into the current CocoaPods.app bundle.
        DESC

        self.arguments = 'NAME'

        def initialize(argv)
          @name = argv.shift_argument
          super
        end

        def validate!
          super
          help! "A CocoaPods plugin name is required." unless @name
        end

        def run
          UI.puts "Add your implementation for the cocoapods-plugins-install plugin in #{__FILE__}"
        end
      end
    end
  end
end

