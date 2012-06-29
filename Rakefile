# encoding: utf-8
# -*- ruby -*-

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'rubygems'
require 'bundler/setup'

require "rake"
require "rake/clean"

require "fileutils"
require "attribute-filters"

require 'attribute-filters/version'
require 'hoe'

task :default => [:test]

desc "install by setup.rb"
task :install do
  sh "sudo ruby setup.rb install"
end

### Gem

Hoe.plugin :bundler
Hoe.plugin :yard
Hoe.plugin :gemspec

Hoe.spec 'attribute-filters' do
  developer               ActiveModel::AttributeFilters::DEVELOPER, ActiveModel::AttributeFilters::EMAIL

  self.version         =  ActiveModel::AttributeFilters::VERSION
  self.rubyforge_name  =  ActiveModel::AttributeFilters::NAME
  self.summary         =  ActiveModel::AttributeFilters::SUMMARY
  self.description     =  ActiveModel::AttributeFilters::DESCRIPTION
  self.url             =  ActiveModel::AttributeFilters::URL

  self.remote_rdoc_dir = ''
  self.rsync_args      << '--chmod=a+rX'
  self.readme_file     = 'README.md'
  self.history_file    = 'docs/HISTORY'

  extra_deps          << ['railties',         '~> 3.0']     <<
                         ['activemodel',      '~> 3.0']
  extra_dev_deps      << ['rspec',            '>= 2.6.0']   <<
                         ['yard',             '>= 0.7.2']   <<
                         ['rdoc',             '>= 3.8.0']   <<
                         ['redcarpet',        '>= 2.1.0']   <<
                         ['bundler',          '>= 1.0.10']  <<
                         ['hoe-bundler',      '>= 1.1.0']   <<
                         ['hoe-gemspec',      '>= 1.0.0']

  unless extra_dev_deps.flatten.include?('hoe-yard')
    extra_dev_deps << ['hoe-yard', '>= 0.1.2']
  end
end

task 'Manifest.txt' do
  puts 'generating Manifest.txt from git'
  sh %{git ls-files | grep -v gitignore > Manifest.txt}
  sh %{git add Manifest.txt}
end

task 'ChangeLog' do
  sh %{git log > ChangeLog}
end

desc "Fix documentation's file permissions"
task :docperm do
  sh %{chmod -R a+rX doc}
end

### Sign & Publish

desc "Create signed tag in Git"
task :tag do
  sh %{git tag -s v#{ActiveModel::AttributeFilters::VERSION} -m 'version #{ActiveModel::AttributeFilters::VERSION}'}
end

desc "Create external GnuPG signature for Gem"
task :gemsign do
  sh %{gpg -u #{ActiveModel::AttributeFilters::EMAIL} \
           -ab pkg/#{ActiveModel::AttributeFilters::NAME}-#{ActiveModel::AttributeFilters::VERSION}.gem \
            -o pkg/#{ActiveModel::AttributeFilters::NAME}-#{ActiveModel::AttributeFilters::VERSION}.gem.sig}
end

