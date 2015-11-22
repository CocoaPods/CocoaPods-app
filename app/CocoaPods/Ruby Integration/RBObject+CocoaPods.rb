# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

# TODO Currently need to call NSObject#to_ruby to convert to Ruby types, which
#      is especially important for NSNumber to TrueClass/FalseClass conversion.
#
#      Need to make it so that RubyCocoa automatically invokes the NSObject#to_ruby
#      method after sending a message from the Objective-C side.

class SomeRubyClass
  def some_ruby_method(array, flag)
    { :key => "#{array.to_ruby.first[42]}, you are #{flag.to_ruby ? 'now' : 'not'} rocking with the best!" }
  end
end
