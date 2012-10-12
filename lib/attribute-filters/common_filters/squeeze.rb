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
        extend CommonFilter
        # Squeezes white characters in attributes.
        # 
        # The attrubutes to be squeezed are taken from the attribute set
        # called +should_be_squeezed+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed.
        # 
        # @return [void]
        def squeeze_attributes
          filter_attrs_from_set(:should_be_squeezed) do |atr_val, atr_name, set_obj|
            other_str = set_obj.annotation(atr_name, :squeeze_other_str)
            if other_str.nil?
              AttributeFiltersHelpers.each_element(atr_val, String) do |v|
                v.mb_chars.squeeze.to_s
              end
            else
              AttributeFiltersHelpers.each_element(atr_val, String) do |v|
                v.mb_chars.squeeze(other_str).to_s
              end
            end
          end
        end
        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be squeezed.
          def squeeze_attributes(*args)
            setup_attributes_that :should_be_squeezed, args,
              {
                :squeeze_other_str => [:squeeze_other_str, :other_str, :string, :with_string,
                                       :with_characters, :with_character, :characters]
              }, :squeeze_other_str
          end
          alias_method :squeeze_attribute, :squeeze_attributes
        end # module ClassMethods

        # Squeezes white characters in attributes, removes leading and trailing spaces and newlines.
        # 
        # The attrubutes to be squished are taken from the attribute set
        # called +should_be_squished+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed.
        # 
        # @return [void]
        def squish_attributes
          filter_attrs_from_set(:should_be_squished) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.squish.to_s
            end
          end
        end
        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be squished.
          def squish_attributes(*args)
            attributes_that(:should_be_squished, args)
          end
          alias_method :squish_attribute, :squish_attributes
        end # module ClassMethods
      end # module Squeeze

    include Squeeze

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
