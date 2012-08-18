# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Capitalize module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Capitalizes attributes.
      module Capitalize
        # Capitalizes attributes.
        # 
        # The attrubutes to be capitalized are taken from the attribute set
        # called +should_be_capitalized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        # then any element of the array is changed.
        # 
        # @return [void]
        def capitalize_attributes
          filter_attrs_from_set(:should_be_capitalized) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.capitalize.to_s
            end
          end
        end

        # Fully capitalizes attributes (capitalizes each word and squeezes spaces).
        # 
        # The attrubutes to be fully capitalized are taken from the attribute set
        # called +should_be_fully_capitalized+ and from set +should_be_titleized+.
        # This method is safe to be used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        # then any element of the array is changed.
        # 
        # @return [void]
        def titleize_with_squeezed_spaces
          s = attribute_set(:should_be_fully_capitalized) + attribute_set(:should_be_titleized)
          filter_attrs_from_set(s) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
            end
          end          
        end
        alias_method :fully_capitalize_attributes, :titleize_with_squeezed_spaces
      end # module Capitalize

      # Titleizes attributes.
      module Titleize
        # Titleizes attributes.
        # 
        # The attrubutes to be titleized are taken from the attribute set
        # called +should_be_titleized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        # then any element of the array is changed.
        # 
        # @return [void]
        def titleize_attributes
          filter_attrs_from_set(:should_be_titleized) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.titleize.to_s
            end
          end
        end
      end # module Titleize

      include Capitalize
      include Titleize

    end # module Common
  end # module AttributeFilters
end # module ActiveModel

