require 'osx/objc/oc_import'

module OSX
  def ns_import_all
    OSX.objc_classnames do |klassname|
      # ignore private classes, such as starting with "_".
      if /\A[A-Z]/ =~ klassname && !klassname.include?('.')
        if OSX.const_defined?(klassname)
          next
        end
        OSX.ns_import(klassname)
      end
    end
    return nil
  end
  module_function :ns_import_all
end

# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

app_bundle = OSX::NSBundle.mainBundle
bundle_path = File.join(app_bundle.resourcePath, 'bundle')
incorrect_root = File.join(app_bundle.bundlePath, 'Contents/MacOS')

# Fix all load paths to point to the bundled Ruby.
$LOAD_PATH.map! do |path|
  path.sub(incorrect_root, bundle_path)
end
