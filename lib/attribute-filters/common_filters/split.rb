# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Split module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Splits attributes.
      module Split
        extend CommonFilter
        # Splits attributes and writes the results into other attributes.
        # 
        # The attrubutes to be splitted are taken from the attribute set
        # called +should_be_splitted+. This method is safe to be
        # used with multibyte strings (containing diacritics).
        # 
        # The pattern used to split a string and the optional limit argument
        # should be set using the model's class method +split_attribute+
        # or directly with annotations.
        def split_attributes
          for_each_attr_from_set(:should_be_splitted) do |atr_val, atr_name, set_obj|
            pattern, limit, flatten, into = set_obj.annotation(atr_name,  :split_pattern, :split_limit,
                                                                          :split_flatten, :split_into)
            if limit.nil?
              r = AttributeFiltersHelpers.each_element(atr_val, String) do |v|
                v.mb_chars.split(pattern)
              end
            else
              r = AttributeFiltersHelpers.each_element(atr_val, String) do |v|
                v.mb_chars.split(pattern, limit)
              end
            end
            r = [ r ] unless r.is_a?(Array)
            r.flatten! if flatten

            # writing collected slices
            if into.blank?
              public_send("#{atr_name}=", r)
            else
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
          # If the separator is not specified and the source attribute is a kind of +String+ then the default
          # separator is applied, which is a whitespace character. You can change that by explicitly setting
          # the separator to +nil+. In such case the split will occuch for each character. If there are more
          # resulting parts then destination attributes then the redundant elements are ignored. If there is
          # a limit given and there are more array elements than attributes then the filter behaves like
          # puts leaves the redundant (unsplittable) and puts it into the last destination attribute.
          # 
          # If the source attribute is an array then the filter will put each element of that array into each
          # destination attribute. If there are more array elements than attributes then the reduntant elements
          # are ignored.
          # 
          # If the destination attributes are not given then the split filter will generate an array and replace
          # currently processed attribute with an array.
          # 
          # The pattern parameter (+:pattern+ when using +split_attributes+ class method or +:split_pattern+ when directly
          # annotating attribute in a set) should be a string. If you would like to separate each character
          # you have to set it to +nil+.
          # 
          # @example
          #   class User < ActiveRecord::Base
          #     include ActiveModel::AttributeFilters::Common::Split
          #   
          #     attr_virtual      :real_name
          #     attr_accessible   :real_name
          #     split_attributes  :real_name, :limit => 2, :into => [ :first_name, :last_name ], :pattern => ' '
          #     before_validation :split_attributes
          #   end
          #   
          # @example
          #   class User < ActiveRecord::Base
          #     include ActiveModel::AttributeFilters::Common::Split
          #   
          #     attr_virtual      :real_name
          #     attr_accessible   :real_name
          #     attributes_that   :should_be_splitted =>  { :real_name =>
          #                                                   { :limit => 2,
          #                                                     :into => [ :first_name, :last_name ],
          #                                                     :pattern => ' ' } }
          #     before_validation :split_attributes
          #   end
          # 
          # @param atr_name [String,Symbol] attribute name
          # @param parameters [Hash] parameters hash # fixme: add YARD parameters explained
          # @return [void]
          def split_attribute(atr_name, parameters = nil)
            atr_name.is_a?(Hash) and return atr_name.each_pair { |k, v| split_attribute(k, v) }
            parameters = { :into => parameters } unless parameters.is_a?(Hash)
            the_attribute(atr_name, :should_be_splitted)
            a = attributes_that(:should_be_splitted)
            pattern = parameters[:with]   || parameters[:pattern] || parameters[:split_pattern]
            into    = parameters[:into]   || parameters[:to]      || parameters[:split_into]
            limit   = parameters[:limit]  || parameters[:split_limit]
            limit   = limit.to_i unless limit.blank?
            flatten = parameters[:flatten] || parameters[:split_flatten]
            if into.blank?
              into = nil
            elsif !into.is_a?(Array)
              into = into.respond_to?(:to_a) ? into.to_a : [ into ]
            end
            a.annotate(atr_name, :split_flatten, flatten)
            a.annotate(atr_name, :split_pattern, pattern)
            a.annotate(atr_name, :split_limit, limit)
            a.annotate(atr_name, :split_into, into)
          end
          alias_method :split_attributes, :split_attribute
        end # module ClassMethods
      end # module Split

    include Split

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
