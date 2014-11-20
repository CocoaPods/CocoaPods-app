Pod::Spec.new do |s|
  s.name         = "ANSIEscapeHelper"
  s.version      = "0.9.6"
  s.summary      = "Objective-C class for translating between ANSI-escaped NSStrings and NSAttributedStrings."
  s.homepage     = "https://github.com/ali-rantakari/ANSIEscapeHelper"
  s.license      = "MIT"
  #s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author       = { "Ali Rantakari" => "visit-with-web-browser@hasseg.org" }
  #s.social_media_url = "http://twitter.com/Ali Rantakari"

  s.source       = { :git => "https://github.com/ali-rantakari/ANSIEscapeHelper.git", :commit => "2931e9e3d162ad76613231358f3d6a77eebd760f" }
  s.source_files = "AMR_ANSIEscapeHelper.{h,m}"
  s.requires_arc = true
end
