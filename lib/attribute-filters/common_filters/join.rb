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
            if compact && vals.respond_to?(:compact)
              vals.compact.join(separator)
            elsif vals.respond_to?(:join)
              vals.join(separator)
            else
              vals
            end
          end
        end
        filtering_method :join_attributes, :should_be_joined

        # This submodule contains class methods needed to describe
        # attribute joining.
        module ClassMethods
          # This method parametrizes joining operation for an attribute of the given name.
          # It uses attribute set annotations to register parameters used when joining.
          # 
          # @param atr_name [String,Symbol] attribute name
          # @param parameters [Hash] parameters hash
          # @option parameters :separator [String] separator passed to +join+ method call
          # @option parameters :join_separator [String] separator passed to +join+ method call (alternative name)
          # @option parameters :with [String] separator passed to +join+ method call (alternative name)
          # @option parameters :from [String,Array<String>] names of source attributes used to join
          # @option parameters :join_from [String,Array<String>] names of source attributes used to join (alternative name)
          # @option parameters :source [String,Array<String>] names of source attributes used to join (alternative name)
          # @option parameters :sources [String,Array<String>] names of source attributes used to join (alternative name)
          # @option parameters :compact [Boolean] flag that causes sources to be compacted before joining
          # @option parameters :join_compact [Boolean] flag that causes sources to be compacted before joining (alternative name)
          # @return [void]
          def join_attributes(atr_name, parameters = nil)
            atr_name.is_a?(Hash) and return atr_name.each_pair { |k, v| join_attribute(k, v) }
            # process reversed notation
            p = parameters
            if atr_name.is_a?(Array)
              if p.is_a?(Hash)
                p = p.dup
                dst = [:into, :in, :destination, :join_into].find { |k| p.key?(k) }
                dst.nil? and raise ArgumentError, "you must specify destination attribute using :into => 'attribute_name'"
                p[:from] = atr_name
                return join_attribute(p.delete(dst), p)
              else
                return join_attribute(p, atr_name)
              end
            end
            # setup attribute set
            setup_attributes_that :should_be_joined, { atr_name => p },
              {
                :join_separator   => [ :with, :separator, :join_separator ],
                :join_from        => [ :from, :source, :sources, :join_from ],
                :join_compact     => [ :compact, :join_compact ]
              }, :join_from
          end
          alias_method :join_attribute,         :join_attributes
          alias_method :joint_attribute,        :join_attributes
          alias_method :joint_attributes,       :join_attributes
          alias_method :join_attributes_to,     :join_attributes
          alias_method :join_attributes_into,   :join_attributes
          alias_method :joins_attribute,        :join_attributes
          alias_method :joins_attributes_to,    :join_attributes
          alias_method :joins_attributes_into,  :join_attributes
        end # module ClassMethods
      end # module Join

      include Join

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
