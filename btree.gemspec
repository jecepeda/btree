# frozen_string_literal: true

require_relative "lib/btree/version"

Gem::Specification.new do |spec|
  spec.name = "btree"
  spec.version = Btree::VERSION
  spec.authors = ["jecepeda"]
  spec.email = ["jcepeda@hey.com"]

  spec.summary = "This is a btree implementation in ruby"
  spec.description = "This is a longer description of the btree implementation"
  spec.homepage = "https://github.com/jecepeda/btree"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
