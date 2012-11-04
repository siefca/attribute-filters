# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file loads Attribute Filters goodies into ActiveModel.

require 'active_model'

# @abstract This namespace is shared with ActveModel.
module ActiveModel

  if defined?(AttributeMethods)

    AttributeMethods.class_eval do

      # Replaces the ActiveModel::AttributeMethods.inluded method so
      # when the AttributeMethods module is included then
      # the AttributeFilters module is also included.
      def self.included_with_attribute_methods(base)
        base.class_eval do
          include ActiveModel::AttributeFilters
          if method_defined?(:included_without_attribute_methods)
            included_without_attribute_methods(base)
          end
        end
      end
      if singleton_class.method_defined?(:included)
        singleton_class.send(:alias_method, :included_without_attribute_methods, :included)
        singleton_class.send(:alias_method, :included, :included_with_attribute_methods)
      end

    end # ActiveModel::AttributeMethods.class_eval

  end # if defined?(AttributeMethods)

end # module ActiveModel
