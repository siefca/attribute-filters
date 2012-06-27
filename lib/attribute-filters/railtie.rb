# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file loads Attribute Filters goodies into Rails.

require 'attribute-filters'

module AttributeFilters
  require 'rails'
  
  # This class is a glue that allows us to integrate with Rails.
  class Railtie < ::Rails::Railtie
    # Alters ActiveModel::AttributeMethods.inluded method so
    # when that module is included the ActiveModel::AttributeFilters
    # module is also included.
    def self.insert
      require 'active_model'
      if defined?(ActiveModel::AttributeMethods)

        ActiveModel::AttributeMethods.class_eval do

          def self.included_with_attribute_methods(base)
            base.class_eval do
              include ActiveModel::AttributeFilters
              if method_defined?(:included_without_attribute_methods)
                included_without_attribute_methods(base)
              end
            end
          end
          if singleton_class.method_defined?(:included)      
            singleton_class.send(:alias_method_chain, :included, :attribute_methods)
          end

        end # ActiveModel::AttributeMethods.class_eval

      end # if defined?(ActiveModel::AttributeMethods)
    end # def self.insert
  end # class Railtie

  class Railtie
    AttributeFilters::Railtie.insert
  end # class Railtie
end # module AttributeFilters
