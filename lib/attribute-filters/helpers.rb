# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains some helper methods for Attribute Filters.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters

    # This module contains internal helpers
    # used to process filters and sets.
    module AttributeFiltersHelpers

      # @private
      def process_flags(args)
        flags = ActiveModel::AttributeFilters::PROCESSING_FLAGS.dup
        while flags.key?(a=args[0]) do
          flags[a] = !!args.shift
        end
        flags
      end
      module_function :process_flags

      # @private
      def check_wanted_methods(o)
        unless o.method_defined?(:changes)
          raise NoMethodError, "Model class must implement 'changes' method in order to use AttributeFilters"
        end
        unless o.method_defined?(:attributes)
          raise NoMethodError, "Model class must implement 'attributes' method in order to use AttributeFilters"
        end
      end
      module_function :check_wanted_methods

      # @private
      def each_element(value, must_be = nil, &block)
        if value.is_a?(Array)
          value.map { |v| each_element(v, must_be, &block) }
        elsif value.is_a?(Hash)
          value.each_with_object(value.class.new) { |(k,v),n| n[k] = each_element(v, must_be, &block) }
        elsif must_be.nil? || value.is_a?(must_be)
          yield(value)
        else
          value
        end
      end
      module_function :each_element

      # @private
      def safe_dup(src)
        src.respond_to?(:deep_dup) ? src.deep_dup : (src.is_a?(Enumerable) ? src.dup : src)
      end
      module_function :safe_dup

    end # module AttributeFiltersHelpers
  end # module AttributeFilters
end # module ActiveModel
