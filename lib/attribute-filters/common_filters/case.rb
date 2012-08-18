# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Case module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common   
      # Downcases attributes.
      module Downcase
        extend CommonFilter
        # Downcases attributes.
        # 
        # The attrubutes to be downcased are taken from the attribute set
        # called +should_be_downcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed.
        # 
        # @return [void]
        def downcase_attributes
          filter_attrs_from_set(:should_be_downcased) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.downcase.to_s
            end
          end
        end

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be downcased.
          def downcase_attributes(*args)
            attributes_that(:should_be_downcased, args)
          end
          alias_method :downcase_attribute, :downcase_attributes
        end # module ClassMethods
      end

      # Upcases attributes.
      module Upcase
        extend CommonFilter
        # Upcases attributes.
        # 
        # The attrubutes to be upcased are taken from the attribute set
        # called +should_be_upcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed.
        # 
        # @return [void]
        def upcase_attributes
          filter_attrs_from_set(:should_be_upcased) do |atr|
            AttributeFiltersHelpers.each_element(atr, String) do |v|
              v.mb_chars.upcase.to_s
            end
          end
        end

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be upcased.
          def upcase_attributes(*args)
            attributes_that(:should_be_upcased, args)
          end
          alias_method :upcase_attribute, :upcase_attributes
        end # module ClassMethods
      end

      # Operates on attributes' case.
      module Case
        include Upcase
        include Downcase
      end

      include Case

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
