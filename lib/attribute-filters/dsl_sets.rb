# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains modules defining methods that create DSL for managing attribute sets.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  # This module contains instance methods for getting and setting
  # attribute sets established in classes (models).
  module AttributeFilters
    # This method is called when the module is included into some class.
    # It simply calls +extend+ on the class with +ClassMethods+ passed as an argument
    # in order to add some DSL class methods to the model.
    # @return [void]
    def self.included(base)
      base.extend ClassMethods
    end

    # Returns the attribute set of the given name.
    # @note The returned value is a duplicate. Adding or removing
    #  elements to it will have no effect. Altering attribute sets
    #  is possible on a class-level only, since attribute sets
    #  are part of models' interfaces.
    # 
    # @param set_name [Symbol] name of attribute set
    # @return [AttributeSet] attribute set
    def attribute_set(set_name)
      ActiveModel::AttributeSet::Query.new(self.class.attribute_set(set_name), self)
    end
    alias_method :attributes_that_are,        :attribute_set
    alias_method :from_attributes_that,       :attribute_set
    alias_method :are_attributes_that_are,    :attribute_set
    alias_method :from_attributes_that_are,   :attribute_set
    alias_method :within_attributes_that_are, :attribute_set
    alias_method :attributes_that,            :attribute_set
    alias_method :attributes_are,             :attribute_set
    alias_method :attributes_for,             :attribute_set
    alias_method :are_attributes,             :attribute_set
    alias_method :are_attributes_for,         :attribute_set
    alias_method :attributes_set,             :attribute_set
    alias_method :properties_that,            :attribute_set

    # Returns a set containing all attributes.
    # @return [AttributeSet] attribute set
    def all_attributes
      ActiveModel::AttributeSet::Query.new(AttributeSet.new(attributes.keys), self)
    end

    # Gets all the defined attribute sets.
    # @note Use +key+ method explicitly to check if the given set exists. The hash returned by this method
    #  will always return {AttributeSet} object. If there is no such set defined then the returned,
    #  matching set will be empty.
    # @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
    def attribute_sets
      self.class.attribute_sets
    end
    alias_method :attributes_sets, :attribute_sets
    alias_method :properties_sets, :attribute_sets

    # Returns the set of set names that the attribute of the given
    # name belongs to.
    # 
    # @note The returned value is a duplicate. Adding or removing
    #  elements to it will have no effect. Altering attribute sets
    #  is possible on a class-level only, since attribute sets
    #  are part of models' interfaces.
    # 
    # @param attribute_name [Symbol] name of attribute set
    # @return [AttributeSet] attribute set
    def filtered_attribute(attribute_name)
      ActiveModel::AttributeSet::AttrQuery.new(self.class.filter_attribute(attribute_name), self)
    end
    alias_method :the_attribute,        :filtered_attribute
    alias_method :is_the_attribute,     :filtered_attribute
    alias_method :are_attributes,       :filtered_attribute
    alias_method :are_the_attributes,   :filtered_attribute

    # Gets all the defined attribute set names hashed by attribute names.
    # @note Use +key+ method explicitly to check if the given attribute is assigned to any set. The hash
    #  returned by this method will always return {AttributeSet} object. If the attribute is not assigned
    #  to any set then the returned, matching set will be empty.
    # @return [Hash{String => AttributeSet<Symbol>}] the collection of attribute set names indexed by attribute names
    def attributes_to_sets
      self.class.attributes_to_sets
    end
    alias_method :attribute_sets_map, :attributes_to_sets

    # This module contains class methods
    # that create DSL for managing attribute sets.
    module ClassMethods
      # @overload attribute_set()
      #   Gets all the defined attribute sets.
      #   @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
      # 
      # @overload attribute_set(set_name)
      #   Gets the contents of an attribute set of the given name.
      #   @param set_name [Symbol,String] name of a set
      #   @return [AttributeSet<String>] the collection of attribute sets
      # 
      # @overload attribute_set(set_name, *attribute_names)
      #   Adds new attributes to a set of attributes.
      #   @param set_name [Symbol,String] name of a set
      #   @param attribute_names [Array<Symbol,String>] names of attributes to be stored in set
      #   @return [nil]
      # 
      # @overload attribute_set(associations)
      #   Adds new attributes to a set of attributes.
      #   @param associations [Hash{Symbol,String => Array<Symbol,String>}] hash containing set names
      #    and arrays of attributes
      #   @return [nil]
      # 
      # @overload attribute_set(associations, *attribute_names)
      #   Creates one new set of attributes of the given names.
      #   @param associations [Hash{Symbol,String => String,Array<Symbol,String>}] hash containing set names
      #    and arrays of attributes
      #   @param attribute_names [Array<Symbol,String>] names of additional attributes to be stored in set
      #   @return [nil]
      def attribute_set(*args)
        AttributeFiltersHelpers.check_wanted_methods(self)
        case args.size
        when 0
          attribute_sets
        when 1
          first_arg = args.first
          if first_arg.is_a?(Hash)
            first_arg.each_pair { |k, v| attribute_set(k, v) }
            nil
          else
            attribute_sets[first_arg.to_sym]
          end
        else
          first_arg = args.shift
          if first_arg.is_a?(Hash)
            first_arg.each_pair do |k, v|
              attribute_set(k, v, args)
            end
          else
            set_name = first_arg.to_sym
            atrs = args.flatten.compact.map{|a|a.to_s}.freeze
            atrs.each do |atr_name|
              __attributes_to_sets_map[atr_name] ||= ActiveModel::AttributeSet.new
              __attributes_to_sets_map[atr_name] << set_name
            end
            __attribute_sets[set_name] ||= ActiveModel::AttributeSet.new
            __attribute_sets[set_name] << atrs
          end
          nil
        end
      end
      alias_method :attributes_that_are,  :attribute_set
      alias_method :attributes_that,      :attribute_set
      alias_method :attributes_are,       :attribute_set
      alias_method :attributes_for,       :attribute_set
      alias_method :attributes_set,       :attribute_set
      alias_method :properties_that,      :attribute_set

      # @overload filter_attribute()
      #   Gets all the defined attribute sets.
      #   @return [Hash{String => AttributeSet<Symbol>}] the collection of
      #    attribute set names indexed by attribute names
      # 
      # @overload filter_attribute(attribute_name)
      #   Gets the names of all attribute sets that an attribute of the given name belongs to.
      #   @param attribute_name [Symbol,String] attribute name
      #   @return [AttributeSet<Symbol>] the collection of attribute set names
      # 
      # @overload filter_attribute(attribute_name, *set_names)
      #   Adds an attribute of the given name to attribute sets.
      #   @param attribute_name [Symbol,String] name of an attribute
      #   @param set_names [Array<Symbol,String>] names of attribute sets to add the attribute to
      #   @return [nil]
      # 
      # @overload filter_attribute(associations)
      #   Adds an attribute of the given name to attribute sets.
      #   @param associations [Hash{Symbol,String => Array<Symbol,String>}] hash containing attribute names
      #    and arrays of attribute set names
      #   @return [nil]
      # 
      # @overload filter_attribute(associations, *set_names)
      #   Creates one new set of attributes of the given names.
      #   @param associations [Hash{Symbol,String => String,Array<Symbol,String>}] hash containing attribute names
      #    and arrays of attribute set name
      #   @param set_names [Array<Symbol,String>] names of additional sets to assign attributes to
      #   @return [nil]
      def filter_attribute(*args)
        AttributeFiltersHelpers.check_wanted_methods(self)
        case args.size
        when 0
          attributes_to_sets
        when 1
          first_arg = args.first
          if first_arg.is_a?(Hash)
            first_arg.each_pair { |k, v| filter_attribute(k, v) }
            nil
          else
            attributes_to_sets[first_arg.to_s]
          end
        else
          first_arg = args.shift
          if first_arg.is_a?(Hash)
            first_arg.each_pair do |k, v|
              filter_attribute(k, v, args)
            end
          else
            first_arg = first_arg.to_s
            args.flatten.compact.each do |set_name|
              attribute_set(set_name, first_arg)
            end
          end
          nil
        end
      end
      alias_method :the_attribute,        :filter_attribute
      alias_method :add_attribute_to_set, :filter_attribute
      alias_method :add_attribute_to_sets,:filter_attribute
      alias_method :attribute_to_set,     :filter_attribute
      alias_method :filtered_attribute,   :filter_attribute
      alias_method :filtered_attributes,  :filter_attribute

      # Gets all the defined attribute sets.
      # @note Use +key+ method explicitly to check if the given set exists. The hash returned by this method
      #  will always return {AttributeSet} object. If there is no such set defined then the returned,
      #  matching set will be empty.
      # @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
      def attribute_sets
        d = __attribute_sets.dup
        d.default = ActiveModel::AttributeSet.new
        d
      end
      alias_method :attributes_sets, :attribute_sets
      alias_method :properties_sets, :attribute_sets

      # Gets all the defined attribute set names hashed by attribute names.
      # @note Use +key+ method explicitly to check if the given attribute is assigned to any set. The hash
      #  returned by this method will always return {AttributeSet} object. If the attribute is not assigned
      #  to any set then the returned, matching set will be empty.
      # @return [Hash{String => AttributeSet<Symbol>}] the collection of attribute set names indexed by attribute names
      def attributes_to_sets
        d = __attributes_to_sets_map.dup
        d.default = ActiveModel::AttributeSet.new
        d
      end
      alias_method :attribute_sets_map, :attributes_to_sets

      private

      def __attributes_to_sets_map
        @__attributes_to_sets_map ||= Hash.new
      end

      def __attribute_sets
        @__attribute_sets ||= Hash.new
      end

    end # module ClassMethods
  end # module AttributeMethods
end # module ActiveModel
