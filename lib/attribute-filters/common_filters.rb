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

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
