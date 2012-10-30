# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Order module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common

      # This module contains attribute filters responsible for manipulating order of attribute values.
      module Order
        extend CommonFilter
        # Inverses order of attribute contents.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_reversed+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def reverse_attributes
          filter_attrs_from_set(:should_be_reversed) do |atr_val, atr_name, set_obj|
            if set_obj.annotation(atr_name, :reverse_enumerable)
              atr_val.respond_to?(:reverse) ? atr_val.reverse : atr_val
            else
              AFHelpers.each_element(atr_val) do |v|
                v.respond_to?(:reverse) ? v.reverse : v
              end
            end
          end
        end
        filtering_method :reverse_attributes, :should_be_reversed

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be filled with some values.
          def reverse_attributes(*args)
            setup_attributes_that :should_be_reversed, args,
              :reverse_enumerable => [:enum, :enums, :whole_enums, :reverse_enums, :reverse_enumerable]
          end
          alias_method :reverse_attribute, :reverse_attributes
        end # module ClassMethods
      end # module Order

      # Randomizes order of attribute contents.
      # 
      # The attrubutes are taken from the attribute set
      # called +should_be_shuffled+.
      # 
      # @note If a value of currently processed attribute is an array
      #  then any element of the array is changed. The same with hash (its values are changed).
      # 
      # @return [void]
      def shuffle_attributes
        filter_attrs_from_set(:should_be_shuffled) do |atr_val, atr_name, set_obj|
          shuffle_enum, rng = set_obj.annotation(atr_name, :shuffle_enumerable, :shuffle_generator)
          rng = { :random => rng }
          if shuffle_enum
            if atr_val.is_a?(String)
              atr_val.mb_chars.split("").shuffle(rng).join
            else
              atr_val.respond_to?(:shuffle) ? atr_val.shuffle(rng) : atr_val
            end
          else
            AFHelpers.each_element(atr_val) do |v|
              if v.is_a?(String)
                v.mb_chars.split("").shuffle(rng).join
              else
                v.respond_to?(:shuffle) ? v.shuffle(rng) : v
              end
            end
          end
        end
      end
      filtering_method :shuffle_attributes, :should_be_shuffled

      # This submodule contains class methods used to easily define filter.
      module ClassMethods
        # Registers attributes that should be shuffled.
        def shuffle_attributes(*args)
          setup_attributes_that :should_be_shuffled, args,
            {
              :shuffle_enumerable => [:enum, :enums, :whole_enums, :shuffle_enums, :shuffle_enumerable],
              :shuffle_generator  => [:random_generator, :generator, :rnd, :shuffle_generator]
            }, :shuffle_generator
        end
        alias_method :shuffle_attribute, :shuffle_attributes
      end # module ClassMethods

      include Order

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
