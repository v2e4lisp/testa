# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'testa'

Gem::Specification.new do |spec|
  spec.name          = "testa"
  spec.version       = Testa::VERSION
  spec.authors       = ["wenjun.yan"]
  spec.email         = ["mylastnameisyan@gmail.com"]
  spec.summary       = %q{Simple test framework}
  spec.description   = %q{Simple test framework}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
