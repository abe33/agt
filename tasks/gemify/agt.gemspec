# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '{{name}}/version'

Gem::Specification.new do |spec|
  spec.name          = "{{name}}"
  spec.version       = "{{version}}"
  spec.authors       = ["{{author}}"]
  spec.email         = ["{{email}}"]
  spec.summary       = "{{description}}"
  spec.description   = "{{description}}"
  spec.homepage      = "{{repository}}"
  spec.license       = "{{license}}"

  spec.files         = Dir["{lib,app}/**/*"] + Dir["*.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
