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

  attributes_that should_be_stripped:       [ :email, :real_name ]
  attributes_that should_be_capitalized:    [ :real_name ]
  attributes_that should_be_tested:         [ :test_attribute ]
  attributes_that do_not_exist:             [ :nonexistent_attribute ]

  the_attribute   username:                 [ :should_be_stripped, :should_be_downcased ]

  before_save :strip_names
  before_save :downcase_names
  before_save :capitalize_names

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
