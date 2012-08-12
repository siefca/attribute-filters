# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common module
# containing ready-to-use, common filtering methods.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common

      # @private
      module CommonFilter
        # @private
        def included(base)
          if base == ActiveModel::AttributeFilters::Common
            base::ClassMethods.send(:include, self::ClassMethods)
          else
            base.extend ClassMethods
          end
        end
      end

      extend CommonFilter

      # This module contains class methods used by the DSL
      # to create keywords for common operations.
      module ClassMethods
      end

      # Strips attributes from leading and trailing spaces.
      module Strip
        # Strips attributes from leading and trailing spaces.
        # 
        # The attrubutes to be stripped are taken from the attribute set called
        # +should_be_stripped+. It operates directly on attribute's contents.
        # 
        # @return [void]
        def strip_attributes
          filter_attrs_from_set(:should_be_stripped) { |atr| atr.strip }
        end
      end

      # Downcases attributes.
      module Downcase
        # Downcases attributes.
        # 
        # The attrubutes to be downcased are taken from the attribute set
        # called +should_be_downcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def downcase_attributes
          filter_attrs_from_set(:should_be_downcased) do |atr|
            atr.mb_chars.downcase.to_s
          end
        end
      end

      # Upcases attributes.
      module Upcase
        # Upcases attributes.
        # 
        # The attrubutes to be upcased are taken from the attribute set
        # called +should_be_upcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def upcase_attributes
          filter_attrs_from_set(:should_be_upcased) do |atr|
            atr.mb_chars.upcase.to_s
          end
        end
      end

      # Operates on attributes' case.
      module Case
        include Upcase
        include Downcase
      end

      # Capitalizes attributes.
      module Capitalize
        # Capitalizes attributes.
        # 
        # The attrubutes to be capitalized are taken from the attribute set
        # called +should_be_capitalized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def capitalize_attributes
          filter_attrs_from_set(:should_be_capitalized) do |atr|
            atr.mb_chars.capitalize.to_s
          end
        end

        # Fully capitalizes attributes (capitalizes each word and squeezes spaces).
        # 
        # The attrubutes to be fully capitalized are taken from the attribute set
        # called +should_be_fully_capitalized+ and from set +should_be_titleized+.
        # This method is safe to be used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def titleize_with_squeezed_spaces
          s = attribute_set(:should_be_fully_capitalized) + attribute_set(:should_be_titleized)
          filter_attrs_from_set(s) do |atr|
            atr.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
          end          
        end
        alias_method :fully_capitalize_attributes, :titleize_with_squeezed_spaces

      end

      # Squeezes white characters in attributes.
      module Squeeze
        # Squeezes white characters in attributes.
        # 
        # The attrubutes to be squeezed are taken from the attribute set
        # called +should_be_squeezed+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def squeeze_attributes
          filter_attrs_from_set(:should_be_squeezed) do |atr|
            atr.mb_chars.squeeze.to_s
          end
        end
      end

      # Squeezes white characters in attributes, removes leading and trailing spaces and newlines.
      module Squish
        # Squeezes white characters in attributes, removes leading and trailing spaces and newlines.
        # 
        # The attrubutes to be squished are taken from the attribute set
        # called +should_be_squished+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def squish_attributes
          filter_attrs_from_set(:should_be_squished) do |atr|
            atr.mb_chars.squish.to_s
          end
        end
      end

      # Splits attributes.
      module Split
        extend CommonFilter

        #extend FilterModule
        # Splits attributes and writes the results into other attributes.
        # 
        # The attrubutes to be splitted are taken from the attribute set
        # called +should_be_splitted+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # The pattern used to split a string and the optional limit argument
        # should be set using the model's class method +split_attribute+.
        # 
        # @example TODO
        #   class User < ActiveRecord::Base
        #     include AttributeFilters::Common::Split
        # 
        #     attributes_that should_be_splitted: [ :name ] 
        # 
        #     before_validation :split_attributes
        #   end
        def split_attributes
          for_each_attr_from_set(:should_be_splitted) do |atr_val, atr_name, set_obj|
            pattern, limit, into = set_obj.annotation(atr_name, :split_pattern, :split_limit, :split_into)
            unless into.blank?
              r = limit.nil? ? atr_val.mb_chars.split(pattern) : atr_val.mb_chars.split(pattern, limit)
              into.each_with_index { |dst_atr, i| public_send("#{dst_atr}=", r[i]) }
            end
          end
        end

        # This submodule contains class methods needed to describe
        # attribute splitting.
        module ClassMethods
          # This method parametrizes splitting operation for an attribute of the given name.
          # It uses attribute set annotations to register parameters used when splitting.
          # 
          # @param atr_name [String,Symbol] attribute name
          # @param parameters [Hash] parameters hash # fixme: add YARD parameters explained
          # @return [void]
          def split_attribute(atr_name, parameters = nil)
            atr_name.is_a?(Hash) and return atr_name.each_pair { |k, v| split_attribute(k, v) }
            parameters = { :into => parameters } unless parameters.is_a?(Hash)
            the_attribute(atr_name, :should_be_splitted)
            a = attributes_that(:should_be_splitted)
            pattern = parameters[:with] || parameters[:pattern]
            into    = parameters[:into] || parameters[:to]
            limit   = parameters[:limit]
            limit   = limit.to_i unless limit.blank?
            into    = atr_name  if into.blank?
            into.is_a?(Array) or into = into.respond_to?(:to_a) ? into.to_a : [ into ]
            a.annotate(atr_name, :split_pattern, pattern)
            a.annotate(atr_name, :split_limit, limit)
            a.annotate(atr_name, :split_into, into)
          end
          alias_method :split_attributes, :split_attribute
        end # module ClassMethods

      end

      # Titleizes attributes.
      module Titleize
        # Titleizes attributes.
        # 
        # The attrubutes to be titleized are taken from the attribute set
        # called +should_be_titleized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @return [void]
        def titleize_attributes
          filter_attrs_from_set(:should_be_titleized) do |atr|
            atr.mb_chars.titleize.to_s
          end
        end
      end

      include Case;
      include Strip;
      include Capitalize;
      include Titleize;
      include Squeeze;
      include Squish;
      include Split;

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
