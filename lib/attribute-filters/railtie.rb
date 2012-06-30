# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file loads Attribute Filters goodies into Rails.

require 'attribute-filters'

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    require 'rails'
    
    # This class is a glue that allows us to integrate with Rails.
    class Railtie < ::Rails::Railtie
      # Inserts the AttributeFilters module into ActiveModel
      def self.insert
        require 'attribute-filters/active_model_insert'
      end # def self.insert
    end # class Railtie
  
    class Railtie
      AttributeFilters::Railtie.insert
    end # class Railtie
  end # module AttributeFilters
end # module ActiveModel
