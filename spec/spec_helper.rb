# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'rspec/core'

Bundler.require(:default, :test)

require 'active_support/all'
require 'attribute-filters'

require 'supermodel'
require 'active_record'

class TestModel < SuperModel::Base
  include ActiveModel::AttributeFilters::Common::Strip
  include ActiveModel::AttributeFilters::Common::Case
  include ActiveModel::AttributeFilters::Common::Squeeze

  attributes_that should_be_stripped:       [ :email, :real_name ]
  attributes_that should_be_titleized:      [ :real_name ]
  attributes_that should_be_squeezed:       [ :real_name ]
  attributes_that should_be_tested:         [ :test_attribute ]
  attributes_that do_not_exist:             [ :nonexistent_attribute ]

  the_attribute   username:                 [ :should_be_stripped, :should_be_downcased ]

  before_save :strip_attributes
  before_save :downcase_attributes
  before_save :titleize_attributes
  before_save :squeeze_attributes

  def touch_nonexistent
    filter_attributes_that :do_not_exist do |atr|
      atr
    end
  end

  def add_string
    filter_attributes_that :should_be_tested do |atr|
      atr + "_some_string"
    end
  end

end
