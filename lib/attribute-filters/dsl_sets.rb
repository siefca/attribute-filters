# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains modules defining methods that create DSL for managing attribute sets.

module ActiveModel
  # This module contains instance methods for getting and setting
  # attricute sets established in classes (models).
  module AttributeFilters
    def self.included(base)
      base.extend ClassMethods
    end

    # Allows to access the given attribute set.
    # 
    # @param set_name [Symbol] name of attribute set
    # @return [AttributeSet] attribute set
    def attribute_set(set_name)
      ActiveModel::AttributeSet::Query.new(self.class.attribute_set(set_name), self)
    end
    alias_method :attributes_that_are,        :attribute_set
    alias_method :are_attributes_that_are,    :attribute_set
    alias_method :from_attributes_that_are,   :attribute_set
    alias_method :within_attributes_that_are, :attribute_set
    alias_method :attributes_that,            :attribute_set
    alias_method :attributes_are,             :attribute_set
    alias_method :attributes_for,             :attribute_set
    alias_method :are_attributes,             :attribute_set
    alias_method :are_attributes_for,         :attribute_set
    alias_method :attributes_set,             :attribute_set
    alias_method :are_properties_that_are,    :attribute_set
    alias_method :properties_that_are,        :attribute_set
    alias_method :properties_that,            :attribute_set
    alias_method :properties_are,             :attribute_set
    alias_method :properties_for,             :attribute_set
    alias_method :are_properties,             :attribute_set
    alias_method :are_properties_for,         :attribute_set
    alias_method :are_properties_that_are,    :attribute_set
    alias_method :properties_set,             :attribute_set
  
    # This module contains class methods
    # that create DSL for managing attribute sets.
    module ClassMethods
      # @overload attribute_set()
      #   Gets all defined attribute sets.
      #   @return [Hash{Symbol => AttributeSet}] the collection of attribute sets indexed by their names
      # 
      # @overload attribute_set(set_name)
      #   Gets the contents of an attribute set of the given name.
      #   @param set_name [Symbol,String] name of a set
      #   @return [AttributeSet] the collection of attribute sets
      # 
      # @overload attribute_set(set_name, *attribute_names)
      #   Creates new set of attributes of the given name.
      #   @param set_name [Symbol,String] name of a set
      #   @param attribute_names [Array<Symbol,String>] names of attributes to be stored in set
      #   @return [nil]
      # 
      # @overload attribute_set(set_options)
      #   Creates one new set or many new sets of attribute of the given name.
      #   @param set_options [Hash{Symbol,String => Array<Symbol,String>}] hash containing set names and arrays of attributes
      #   @return [nil]
      # 
      # @overload attribute_set(set_options, *attribute_names)
      #   Creates one new set of attributes of the given names.
      #   @param set_options [Hash{Symbol,String => String,Array<Symbol,String>}] hash containing set names and arrays of attributes
      #   @param attribute_names [Array<Symbol,String>] names of additional attributes to be stored in set
      #   @return [nil]
      def attribute_set(*args)
        case args.size
        when 0
          attribute_sets
        when 1
          first_arg = args.first
          if first_arg.is_a?(Hash)
            first_arg.each_pair { |k,v| attribute_set(k,v) }
            nil
          else
            attribute_sets[first_arg.to_sym] || ActiveModel::AttributeSet.new.freeze
          end
        else
          first_arg = args.shift
          if first_arg.is_a?(Hash)
            first_arg.each_pair do |k,v|
              attribute_set(k,v,args)
            end
          else
            set_name = first_arg.to_sym
            attribute_sets[set_name] = ActiveModel::AttributeSet.new(args.flatten.compact.map{|a|a.to_s}).freeze
          end
          nil
        end
      end
      alias_method :attributes_that_are,  :attribute_set
      alias_method :attributes_that,      :attribute_set
      alias_method :attributes_are,       :attribute_set
      alias_method :attributes_for,       :attribute_set
      alias_method :attributes_set,       :attribute_set
      alias_method :properties_that_are,  :attribute_set
      alias_method :properties_that,      :attribute_set
      alias_method :properties_are,       :attribute_set
      alias_method :properties_for,       :attribute_set
      alias_method :properties_set,       :attribute_set

      # Gets all defined attribute sets.
      # @return [Hash{Symbol => AttributeSet}] the collection of attribute sets indexed by their names
      def attribute_sets
        @__attribute_sets ||= Hash.new
      end
      alias_method :attributes_sets, :attribute_sets
      alias_method :properties_sets, :attribute_sets
    end # module ClassMethods
  end # module AttributeMethods
end # module ActiveModel
