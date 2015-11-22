# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

app_bundle = OSX::NSBundle.mainBundle
bundle_path = File.join(app_bundle.resourcePath, 'bundle')
rubycocoa_framework = File.join(app_bundle.privateFrameworksPath, 'RubyCocoa.framework/Versions/A')

# Fix all load paths to point to the bundled Ruby.
$LOAD_PATH.map! do |path|
  path.sub(rubycocoa_framework, bundle_path)
end

require 'rubygems'

class SomeRubyClass
  def some_ruby_method(array, flag)
    { :key => "#{array.first[42]}, you are #{flag ? 'now' : 'not'} rocking with the best!" }
  end
end
