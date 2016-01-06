# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-plugins-install/gem_version.rb'
require 'yaml'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-plugins-install"
  spec.version       = CocoapodsPluginsInstall::VERSION
  spec.authors       = ["Eloy Durán"]
  spec.email         = ["eloy.de.enige@gmail.com"]
  spec.summary       = %q{Adds installation powers to cocoapods-plugins, specifically for CocoaPods.app}
  spec.homepage      = "https://github.com/CocoaPods/CocoaPods.app/blob/master/cocoapods-plugins-install"
  spec.license       = "MIT"

  spec.files         = Dir.glob('lib/**/*.rb') << __FILE__
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  version_file = File.expand_path('~/.cocoapods/repos/master/CocoaPods-version.yml')
  install_cocoapods_version = YAML.load(File.read(version_file))['last']

  spec.add_runtime_dependency "cocoapods-plugins", installed_cocoapods_version

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.4"
end
