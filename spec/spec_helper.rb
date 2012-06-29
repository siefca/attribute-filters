require 'rubygems'
require 'bundler/setup'
require 'rspec/core'

Bundler.require(:default, :development)

require 'active_support/all'
require 'attribute-filters'

class TestModel < SuperModel::Base

  attributes_that should_be_stripped:       [ :username, :email, :real_name ]
  attributes_that should_be_downcased:      [ :username ]
  attributes_that should_be_capitalized:    [ :real_name ]
  attributes_that should_be_deeply_tested:  [ :test_attribute ]
  attributes_that does_not_exist:           [ :nonexistent_attribute ]

  before_save :strip_names
  before_save :downcase_names
  before_save :capitalize_names

  def downcase_names
    filter_attributes_that :should_be_downcased do |atr|
      atr.mb_chars.downcase.to_s
    end
  end

  def capitalize_names
    filter_attributes_that :should_be_capitalized do |atr|
      atr.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
    end
  end

  def strip_names
    for_attributes_that(:should_be_stripped) { |atr| atr.strip! }
  end
end
