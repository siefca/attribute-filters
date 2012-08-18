# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Squeeze module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Squeezes white characters in attributes.
      module Squeeze
        # Squeezes white characters in attributes.
        # 
        # The attrubutes to be squeezed are taken from the attribute set
        # called +should_be_squeezed+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        # then any element of the array is changed.
        # 
        # @return [void]
        def squeeze_attributes
          filter_attrs_from_set(:should_be_squeezed) do |atr|
            AttributeFiltersHelpers.each_element(atr) do |v|
              v.mb_chars.squeeze.to_s
            end
          end
        end
      end # module Squeeze

      # Squeezes white characters in attributes, removes leading and trailing spaces and newlines.
      module Squish
        # Squeezes white characters in attributes, removes leading and trailing spaces and newlines.
        # 
        # The attrubutes to be squished are taken from the attribute set
        # called +should_be_squished+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # # @note If a value of currently processed attribute is an array
        # then any element of the array is changed.
        # 
        # @return [void]
        def squish_attributes
          filter_attrs_from_set(:should_be_squished) do |atr|
            AttributeFiltersHelpers.each_element(atr) do |v|
              v.mb_chars.squish.to_s
            end
          end
        end
      end # module Squish

    include Squeeze
    include Squish

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
