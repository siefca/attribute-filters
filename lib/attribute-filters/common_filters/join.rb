# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Join module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Joins attributes.
      module Join
        extend CommonFilter

        # Joins attributes and writes the results into other attribute.
        # 
        # The attrubutes to be destination for joins are taken from the attribute set
        # called +should_be_joined+.
        # 
        # The pattern used to join a string and the optional separator argument
        # should be set using the model's class method +join_attribute+.
        # 
        # @example TODO
        def join_attributes
          filter_attrs_from_set(:should_be_joined, :process_all, :process_blank) do |atr_val, atr_name, set_obj|
            from, compact = set_obj.annotation(atr_name, :join_from, :join_compact)
            if from.blank?
              next atr_val if !atr_val.is_a?(Array)
              from = [ atr_name ]
            elsif !from.is_a?(Array)
              from = [ from ]
            end
            vals = AttributeSet::Query.new(from, self).values
            separator = set_obj.has_annotation?(atr_name, :join_separator) ?
                        set_obj.annotation(atr_name, :join_separator) : " "
            compact ? vals.compact.join(separator) : vals.join(separator)
          end
        end

        # This submodule contains class methods needed to describe
        # attribute joining.
        module ClassMethods
          # This method parametrizes joining operation for an attribute of the given name.
          # It uses attribute set annotations to register parameters used when joining.
          # 
          # @param atr_name [String,Symbol] attribute name
          # @param parameters [Hash] parameters hash # fixme: add YARD parameters explained
          # @return [void]
          def join_attribute(atr_name, parameters = nil)
            atr_name.is_a?(Hash) and return atr_name.each_pair { |k, v| join_attribute(k, v) }
            if atr_name.is_a?(Array)
              if parameters.is_a?(Symbol) || parameters.is_a?(String)
                return join_attribute(parameters, atr_name)
              elsif parameters.is_a?(Hash)
                dst = parameters.delete(:into) || parameters.delete(:in) || parameters.delete(:destination)
                if dst.nil?
                  raise ArgumentError, "you have to specify destination attribute using :into => 'attribute_name'"
                end
                parameters[:from] = atr_name
                return join_attribute(dst, parameters)
              end
            end
            parameters = { :from => parameters } unless parameters.is_a?(Hash)
            the_attribute(atr_name, :should_be_joined)
            separator = " " unless parameters.key?(:with) || parameters.key?(:separator) || parameters.key?(:join_separator)
            separator ||= parameters[:with] || parameters[:separator] || parameters[:join_separator]
            from        = parameters[:from] || parameters[:source] || parameters[:sources] || parameters[:join_from]
            compact = parameters.key?(:compact) ? !!parameters[:compact] : !!parameters[:join_compact]
            attributes_that(:should_be_joined).tap do |a|
              a.annotate(atr_name, :join_separator, separator)
              a.annotate(atr_name, :join_compact, compact)
              a.annotate(atr_name, :join_from, from)
            end
          end
          alias_method :join_attributes, :join_attribute
        end # module ClassMethods
      end # module Join

      include Join

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
