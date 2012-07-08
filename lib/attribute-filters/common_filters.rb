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
      # 
      # The attrubutes to be stripped are taken from the attribute set called
      # +should_be_stripped+. It operates directly on attribute's contents.
      # 
      # @return [void]
      def strip_attributes
        call_attrs_from_set(:should_be_stripped) { |atr| atr.strip! }
      end

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

      # Capitalize attributes.
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

      # Fully capitalize attributes (capitalize each word).
      # 
      # The attrubutes to be fully capitalized are taken from the attribute set
      # called +should_be_fully_capitalized+. This method is safe to be
      # used with multibyte strings (containing diacritics).
      # 
      # @return [void]
      def fully_capitalize_attributes
        filter_attrs_from_set(:should_be_fully_capitalized) do |atr|
          atr.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
        end
      end

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
