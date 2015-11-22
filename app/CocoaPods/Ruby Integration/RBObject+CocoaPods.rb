# This is required for Foundation classes to be known to this side of the bridge at all.
require 'osx/objc/foundation'

class SomeRubyClass
  def some_ruby_method(array, flag)
    { :key => "#{array.first[42]}, you are #{flag ? 'now' : 'not'} rocking with the best!" }
  end
end
