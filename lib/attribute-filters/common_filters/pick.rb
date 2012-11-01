# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Pick module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Picks attributes from leading and trailing spaces.
      module Pick
        extend CommonFilter
        
        def pick_attributes_core(val, from, to, range, step)
          from  ||= 0
          to    ||= val.size - 1
          step  ||= 1
          range ||= from..to
          range.step(step).map { |n| val[n] }
        end
        private :pick_attributes_core

        # Picks attributes from leading and trailing spaces.
        # 
        # The attrubutes to be picked are taken from the attribute set called
        # +should_be_picked+. It operates directly on attribute's contents.
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def pick_attributes
          filter_attrs_from_set(:should_be_picked) do |atr_val, atr_name, set_obj|
            pick_enum, step, from, to, range, sep, jnt = set_obj.annotation(atr_name, :pick_enumerable, :pick_step,
                                                                                      :pick_from, :pick_to, :pick_range,
                                                                                      :pick_separator, :pick_join)
            if pick_enum
              if atr_val.is_a?(String)
                sep ||= ""
                jnt ||= sep.is_a?(String) ? sep : nil
                pick_attributes_core(atr_val.mb_chars.split(sep), from, to, range, step).join(jnt)
              elsif atr_val.is_a?(Array)
                pick_attributes_core(atr_val, from, to, range, step)
              elsif atr_val.is_a?(Hash)
                Hash[pick_attributes_core(atr_val.to_a, from, to, range, step)]
              else
                atr_val
              end
            else
              sep ||= ""
              jnt ||= sep.is_a?(String) ? sep : nil
              AFHelpers.each_element(atr_val, String) do |v|
                pick_attributes_core(v.mb_chars.split(sep), from, to, range, step).join(jnt)
              end
            end
          end
        end 
        filtering_method :pick_attributes, :should_be_picked

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be picked.
          def pick_attributes(*args)
            setup_attributes_that :should_be_picked, args,
              {
                :pick_enumerable  => [:enum, :enums, :whole_enums, :shuffle_enums, :pick_enumerable],
                :pick_step        => [:step, :with_step, :each, :pick_step],
                :pick_from        => [:from, :head, :take, :first, :pick_first, :pick_head, :pick_from],
                :pick_to          => [:to, :tail, :last, :pick_last, :pick_tail, :pick_to],
                :pick_range       => [:range, :pick_range],
                :pick_separator   => [:separator, :regex, :split_with, :split_separator, :pick_separator],
                :pick_join        => [:joiner, :join, :join_with, :pick_join]
              }, :pick_separator
          end
          alias_method :pick_attribute,   :pick_attributes
          alias_method :picks_attribute,  :pick_attributes
          alias_method :picks_attributes, :pick_attributes
        end # module ClassMethods
      end # module Pick

      include Pick

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
