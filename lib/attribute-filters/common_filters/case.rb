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

      # This module contains attribute filters responsible for changing the case of letters.
      module Case
        extend CommonFilter

        # Downcases attributes.
        # 
        # The attrubutes to be downcased are taken from the attribute set
        # called +should_be_downcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def downcase_attributes
          filter_attrs_from_set(:should_be_downcased) do |atr|
            AFHelpers.each_element(atr, String) do |v|
              v.mb_chars.downcase.to_s
            end
          end
        end
        filtering_method :downcase_attributes, :should_be_downcased

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be downcased.
          def downcase_attributes(*args)
            attributes_that(:should_be_downcased, args)
          end
          alias_method :downcase_attribute,   :downcase_attributes
          alias_method :downcases_attribute,  :downcase_attributes
          alias_method :downcases_attributes, :downcase_attributes
        end # module ClassMethods

        # Upcases attributes.
        # 
        # The attrubutes to be upcased are taken from the attribute set
        # called +should_be_upcased+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def upcase_attributes
          filter_attrs_from_set(:should_be_upcased) do |atr|
            AFHelpers.each_element(atr, String) do |v|
              v.mb_chars.upcase.to_s
            end
          end
        end
        filtering_method :upcase_attributes, :should_be_upcased

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be upcased.
          def upcase_attributes(*args)
            attributes_that(:should_be_upcased, args)
          end
          alias_method :upcase_attribute,   :upcase_attributes
          alias_method :upcases_attribute,  :upcase_attributes
          alias_method :upcases_attributes, :upcase_attributes
        end # module ClassMethods

        # Titleizes attributes.
        # 
        # The attrubutes to be titleized are taken from the attribute set
        # called +should_be_titleized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def titleize_attributes
          filter_attrs_from_set(:should_be_titleized) do |atr|
            AFHelpers.each_element(atr, String) do |v|
              v.mb_chars.titleize.to_s
            end
          end
        end
        filtering_method :titleize_attributes, :should_be_titleized

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be titleized.
          def titleize_attributes(*args)
            attributes_that(:should_be_titleized, args)
          end
          alias_method :titleize_attribute,   :titleize_attributes
          alias_method :titleizes_attribute,  :titleize_attributes
          alias_method :titleizes_attributes, :titleize_attributes
        end # module ClassMethods

        # Capitalizes attributes.
        # 
        # The attrubutes to be capitalized are taken from the attribute set
        # called +should_be_capitalized+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def capitalize_attributes
          filter_attrs_from_set(:should_be_capitalized) do |atr|
            AFHelpers.each_element(atr, String) do |v|
              v.mb_chars.capitalize.to_s
            end
          end
        end
        filtering_method :capitalize_attributes, :should_be_capitalized

        # Fully capitalizes attributes (capitalizes each word and squeezes spaces).
        # 
        # The attrubutes to be fully capitalized are taken from the attribute set
        # called +should_be_fully_capitalized+ and from set +should_be_titleized+.
        # This method is safe to be used with multibyte strings (containing diacritics).
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def fully_capitalize_attributes
          filter_attrs_from_set(:should_be_fully_capitalized) do |atr|
            AFHelpers.each_element(atr, String) do |v|
              v.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
            end
          end          
        end
        filtering_method  :fully_capitalize_attributes, :should_be_fully_capitalized
        alias_method      :titleize_with_squeezed_spaces, :fully_capitalize_attributes

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be capitalized.
          def capitalize_attributes(*args)
            attributes_that(:should_be_capitalized, args)
          end
          alias_method :capitalize_attribute,   :capitalize_attributes
          alias_method :capitalizes_attribute,  :capitalize_attributes
          alias_method :capitalizes_attributes, :capitalize_attributes

          # Registers attributes that should be fully capitalized.
          def fully_capitalize_attributes(*args)
            attributes_that(:should_be_fully_capitalized, args)
          end
          alias_method :fully_capitalize_attribute,    :fully_capitalize_attributes
          alias_method :fully_capitalizes_attribute,   :fully_capitalize_attributes
          alias_method :fully_capitalizes_attributes,  :fully_capitalize_attributes
          alias_method :titleize_with_squeezed_spaces, :fully_capitalize_attributes
        end # module ClassMethods
      end # module Case

      include Case

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
