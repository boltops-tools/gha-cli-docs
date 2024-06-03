lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cli_docs/version"

Gem::Specification.new do |spec|
  spec.name = "cli-docs"
  spec.version = CliDocs::VERSION
  spec.authors = ["Tung Nguyen"]
  spec.summary = "CLI Docs Generator"
  spec.homepage = "https://github.com/boltops-tools/cli-docs"
  spec.license = "MIT"

  spec.files = File.directory?(".git") ? `git ls-files`.split($/) : Dir.glob("**/*")
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "memoist"
  spec.add_dependency "rainbow"
  spec.add_dependency "render_me_pretty"
  spec.add_dependency "thor"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "cli_markdown"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
