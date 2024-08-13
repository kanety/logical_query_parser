# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logical_query_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "logical_query_parser"
  spec.version       = LogicalQueryParser::VERSION
  spec.authors       = ["Yoshikazu Kaneta"]
  spec.email         = ["kaneta@sitebridge.co.jp"]

  spec.summary       = %q{A parser for a logical query string.}
  spec.description   = %q{A parser to generate a tree structure from a logical query string using treetop.}
  spec.homepage      = "https://github.com/kanety/logical_query_parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "treetop", "~> 1.6.8"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
