# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

service_bundle = OSX::NSBundle.mainBundle
bundle_path = File.expand_path('../../Resources/bundle', service_bundle.bundlePath)
incorrect_root = File.join(service_bundle.bundlePath, 'Contents/MacOS')

# Fix all load paths to point to the bundled Ruby.
$LOAD_PATH.map! do |path|
  path.sub(incorrect_root, bundle_path)
end

module Pod
  module App
    # Doing this here so that you get nicer errors when a require fails.
    def self.require_gems
      require 'rubygems'
      require 'cocoapods-core'

      require 'claide/command/plugin_manager'
      require 'claide/ansi'
      CLAide::ANSI.disabled = true
    end
  end
end