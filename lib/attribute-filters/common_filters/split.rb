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
            if atr_val.is_a?(Array)
              if pattern.nil?
                if limit.nil?
                  next if into.blank?
                  r = atr_val
                else
                  r = atr_val.take(limit)
                end
              else
                r = []
                if limit.nil?
                  atr_val.each { |v| r.push(*(v.mb_chars.split(pattern))) }
                else
                  l = limit
                  if limit > 0
                    atr_val.each do |v|
                      rr = v.mb_chars.split(pattern, l)
                      l -= rr.size
                      r.push(*rr)
                      break if l <= 0
                    end
                  end
                end
              end
            else
              r = limit.nil? ? atr_val.mb_chars.split(pattern) : atr_val.mb_chars.split(pattern, limit)
            end
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
          # @param atr_name [String,Symbol] attribute name
          # @param parameters [Hash] parameters hash # fixme: add YARD parameters explained
          # @return [void]
          def split_attribute(atr_name, parameters = nil)
            atr_name.is_a?(Hash) and return atr_name.each_pair { |k, v| split_attribute(k, v) }
            parameters = { :into => parameters } unless parameters.is_a?(Hash)
            the_attribute(atr_name, :should_be_splitted)
            a = attributes_that(:should_be_splitted)
            pattern = parameters[:with] || parameters[:pattern] || parameters[:split_pattern]
            into    = parameters[:into] || parameters[:to] || parameters[:split_into]
            limit   = parameters[:limit] || parameters[:split_limit]
            limit   = limit.to_i unless limit.blank?
            if into.blank?
              into = nil
            elsif !into.is_a?(Array)
              into = into.respond_to?(:to_a) ? into.to_a : [ into ]
            end
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
