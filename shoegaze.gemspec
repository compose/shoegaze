$LOAD_PATH.push File.expand_path("../lib", __dir__)
require File.expand_path('lib/shoegaze/version.rb', __dir__)

Gem::Specification.new do |s|
  s.name        = "shoegaze"
  s.version     = Shoegaze::VERSION
  s.authors     = ["Dan Connor"]
  s.email       = ["dan@danconnor.com"]
  s.homepage    = "https://github.com/compose/shoegaze"
  s.summary     = "Create mocks of modules (especially clients) with " \
                  "easily-defined scenarios (success, invalid, etc)"
  s.description = "Create mocks of modules (especially clients) with " \
                  "easily-defined scenarios (success, invalid, etc)"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*",
                "spec/features/**/*",
                "spec/unit/**/*",
                "spec/shoegaze/**/*",
                "Rakefile",
                "README.md"]

  s.add_dependency "rspec",         ">= 3.4"
  s.add_dependency "factory_bot",   ">= 6.0"
  s.add_dependency "representable", ">= 2.3.0"
  s.add_dependency "multi_json",    ">= 1.12"
end
