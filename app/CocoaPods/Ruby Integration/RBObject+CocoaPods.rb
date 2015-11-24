# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

app_bundle = OSX::NSBundle.mainBundle
bundle_path = File.join(app_bundle.resourcePath, 'bundle')
incorrect_root = File.join(app_bundle.bundlePath, 'Contents/MacOS')

# Fix all load paths to point to the bundled Ruby.
$LOAD_PATH.map! do |path|
  path.sub(incorrect_root, bundle_path)
end
