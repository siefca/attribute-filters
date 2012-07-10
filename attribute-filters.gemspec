# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "attribute-filters"
  s.version = "1.2.1.20120710092708"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pawe\u{142} Wilk"]
  s.cert_chain = ["/Users/siefca/.gem/gem-public_cert.pem"]
  s.date = "2012-07-10"
  s.description = "Concise way of filtering model attributes in Rails."
  s.email = ["pw@gnu.org"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = [".rspec", ".yardopts", "ChangeLog", "Gemfile", "Gemfile.lock", "LGPL-LICENSE", "Manifest.txt", "README.md", "Rakefile", "attribute-filters.gemspec", "docs/COPYING", "docs/HISTORY", "docs/LEGAL", "docs/LGPL-LICENSE", "docs/TODO", "docs/USAGE.md", "docs/rdoc.css", "docs/yard-tpl/default/fulldoc/html/css/common.css", "init.rb", "lib/attribute-filters.rb", "lib/attribute-filters/active_model_insert.rb", "lib/attribute-filters/attribute_set.rb", "lib/attribute-filters/attribute_set_attrquery.rb", "lib/attribute-filters/attribute_set_enum.rb", "lib/attribute-filters/attribute_set_query.rb", "lib/attribute-filters/common_filters.rb", "lib/attribute-filters/dsl_filters.rb", "lib/attribute-filters/dsl_sets.rb", "lib/attribute-filters/helpers.rb", "lib/attribute-filters/railtie.rb", "lib/attribute-filters/version.rb", "spec/attribute-filters_spec.rb", "spec/spec_helper.rb", ".gemtest"]
  s.homepage = "https://rubygems.org/gems/attribute-filters/"
  s.rdoc_options = ["--title", "Attribute::Filters Documentation", "--quiet"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "attribute-filters"
  s.rubygems_version = "1.8.11"
  s.signing_key = "/Users/siefca/.gem/gem-private_key.pem"
  s.summary = "Concise way of filtering model attributes in Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, ["~> 3.0"])
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_development_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7.2"])
      s.add_development_dependency(%q<rdoc>, [">= 3.8.0"])
      s.add_development_dependency(%q<redcarpet>, [">= 2.1.0"])
      s.add_development_dependency(%q<supermodel>, [">= 0.1.6"])
      s.add_development_dependency(%q<activerecord>, [">= 3.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.10"])
      s.add_development_dependency(%q<hoe-bundler>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe-gemspec>, [">= 1.0.0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.16"])
    else
      s.add_dependency(%q<railties>, ["~> 3.0"])
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<yard>, [">= 0.7.2"])
      s.add_dependency(%q<rdoc>, [">= 3.8.0"])
      s.add_dependency(%q<redcarpet>, [">= 2.1.0"])
      s.add_dependency(%q<supermodel>, [">= 0.1.6"])
      s.add_dependency(%q<activerecord>, [">= 3.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.10"])
      s.add_dependency(%q<hoe-bundler>, [">= 1.1.0"])
      s.add_dependency(%q<hoe-gemspec>, [">= 1.0.0"])
      s.add_dependency(%q<hoe>, ["~> 2.16"])
    end
  else
    s.add_dependency(%q<railties>, ["~> 3.0"])
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<hoe-yard>, [">= 0.1.2"])
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<yard>, [">= 0.7.2"])
    s.add_dependency(%q<rdoc>, [">= 3.8.0"])
    s.add_dependency(%q<redcarpet>, [">= 2.1.0"])
    s.add_dependency(%q<supermodel>, [">= 0.1.6"])
    s.add_dependency(%q<activerecord>, [">= 3.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.10"])
    s.add_dependency(%q<hoe-bundler>, [">= 1.1.0"])
    s.add_dependency(%q<hoe-gemspec>, [">= 1.0.0"])
    s.add_dependency(%q<hoe>, ["~> 2.16"])
  end
end
