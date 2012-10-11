# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Fill module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common   

      # This module contains attribute filters responsible for changing the case of letters.
      module Fill
        extend CommonFilter
        # Fills-up attributes that are blank with +nil+ or the given values.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_filled+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed.
        # 
        # @return [void]
        def fill_attributes
          filter_attrs_from_set(:should_be_filled, :process_blank) do |atr_val, atr_name, set_obj|
            AttributeFiltersHelpers.each_element(atr_val) do |v|
              if v.blank? || set_obj.annotation(atr_name, :fill_any)
                set_obj.annotation(atr_name, :fill_value)
              else
                v
              end
            end
          end
        end

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be filled with some values.
          def fill_attributes(*args)
            setup_attributes_that :should_be_filled, args,
                                 { :fill_value  => [:with, :fill_with, :fill_value, :fill, :value, :content, :default],
                                   :fill_any    => [:fill_always, :always_fill, :always, :fill_any, :fill_present]
                                 }, :fill_value
          end
          alias_method :fill_attribute, :fill_attributes
        end # module ClassMethods
      end # module Fill

      include Fill

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
