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

    # Returns the attribute set of the given name or the set containing
    # all attributes (if the argument is not given).
    # 
    # If the given +set_name+ is a kind of String or Symbol then the method
    # returns a copy of a set that is stored within a model class. The copy
    # is wrapped in a `AttributeSet::AttrQuery` instance.
    # 
    # If the argument is a kind of {AttributeSet} then the local set
    # is taken and wrapped in a {AttributeSet::AttrQuery} instance.
    # 
    # If the argument is other kind than the specified above then
    # the method tries to initialize new, local set object and wraps
    # it in a `AttributeSet::AttrQuery` instance.
    # 
    # @note The returned value is a duplicate. Adding or removing
    #  elements to it will have no effect on class-level set.
    #  Altering attribute sets is possible on a class-level only, since attribute sets
    #  are part of models' interfaces.
    # 
    # @param set_name [Symbol] name of attribute set, attribute object or any object that can initialize a set
    # @return [AttributeSet] attribute set
    def attribute_set(set_name = nil)
      if set_name.nil?
        all_attributes
      else
        ActiveModel::AttributeSet::Query.new(set_name, self)
      end
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

    # Returns the attribute set of the given name without wrapping
    # the result in proxy methods.
    # 
    # @note The returned value is a duplicate. Adding or removing
    #  elements to it will have no effect. Altering attribute sets
    #  is possible on a class-level only, since attribute sets
    #  are part of models' interfaces.
    # 
    # @param set_name [Symbol] name of attribute set
    # @return [AttributeSet] attribute set
    def attribute_set_simple(set_name)
      self.class.attribute_set(set_name).deep_dup
    end

    # Returns a set containing all known attributes
    # without wrapping the result in a proxy.
    # 
    # @return [AttributeSet] attribute set
    def all_attributes(simple = false, no_presence_check = true)
      my_class = self.class
      c = my_class.send(:__attribute_filters_semi_real)
      c = c.select_accessible(self) unless no_presence_check || c.empty?
      r = ActiveModel::AttributeSet.new(c)
      r.merge!(my_class.send(:__attribute_filters_virtual))
      r << attributes.keys
      if respond_to?(:accessible_attributes)
        r << accessible_attribute
        r << protected_attributes
      end
      r = r.deep_dup
      simple ? r : ActiveModel::AttributeSet::Query.new(r, self)
    end

    # Returns a set containing all accessible attributes.
    # 
    # @param simple [Boolean] optional parameter that disables
    #   wrapping a resulting set in a proxy (defaults to +false+)
    # @return [AttributeSet] attribute set
    def all_accessible_attributes(simple = false)
      my_class = self.class
      c = my_class.respond_to?(:accessible_attributes) ? my_class.accessible_attributes : []
      simple ? AttributeSet.new(c) : AttributeSet::Query.new(c)
    end
    alias_method :accessible_attributes_set, :all_accessible_attributes

    # Returns a set containing all protected attributes.
    # 
    # @param simple [Boolean] optional parameter that disables
    #   wrapping a resulting set in a proxy (defaults to +false+)
    # @return [AttributeSet] attribute set
    def all_protected_attributes(simple = false)
      my_class = self.class
      c = my_class.respond_to?(:protected_attributes) ? my_class.protected_attributes : []
      simple ? AttributeSet.new(c) : AttributeSet::Query.new(c)
    end
    alias_method :protected_attributes_set, :all_protected_attributes

    # Returns a set containing attributes declared as virtual with +attr_virtual+.
    # 
    # @param simple [Boolean] optional parameter that disables
    #   wrapping a resulting set in a proxy (defaults to +false+)
    # @return [AttributeSet] attribute set
    def all_virtual_attributes(simple = false)
      c = self.class.attribute_filters_virtual
      simple ? c : AttributeSet::Query.new(c)
    end
    alias_method :virtual_attributes_set, :all_virtual_attributes
    alias_method :attribute_filters_virtual, :all_virtual_attributes

    # Returns a set containing attributes declared as semi-real.
    # 
    # @param simple [Boolean] optional parameter that disables
    #   wrapping a resulting set in a proxy (defaults to +false+)
    # @param no_presence_check [Boolean] optional parameter that
    #  disables checking for presence of setters and getters for each
    #  attribute (defaults to +true+)
    # @return [AttributeSet] attribute set
    def all_semi_real_attributes(simple = false, no_presence_check = true)
      c = self.class.treat_as_real
      c = c.select_accessible(self) unless no_presence_check || c.empty? 
      simple ? c : AttributeSet::Query.new(c)
    end
    alias_method :semi_real_attributes_set, :all_semi_real_attributes
    alias_method :treat_as_real, :all_semi_real_attributes


    # Returns a set containing all attributes that are not accessible attributes.
    # @return [AttributeSet] attribute set
    def all_inaccessible_attributes
      all_attributes - all_accessible_attributes(true)
    end
    alias_method :all_non_accessible_attributes,  :all_inaccessible_attributes
    alias_method :inaccessible_attributes_set,    :all_inaccessible_attributes

    # Gets all the defined attribute sets.
    # 
    # @note Use +key+ method explicitly to check if the given set exists. The hash returned by this method
    #  will always return {AttributeSet} object. If there is no such set defined then the returned,
    #  matching set will be empty.
    # 
    # @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
    def attribute_sets
      s = self.class.attribute_sets
      s.each_pair do |set_name, set_object|
        s[set_name] = ActiveModel::AttributeSet::Query.new(set_object, self)
      end
      s.default = ActiveModel::AttributeSet::Query.new(ActiveModel::AttributeSet.new.freeze, self)
      s
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
      ActiveModel::AttributeSet::AttrQuery.new(self.class.filter_attribute(attribute_name), self, attribute_name)
    end
    alias_method :the_attribute,        :filtered_attribute
    alias_method :is_the_attribute,     :filtered_attribute
    alias_method :are_attributes,       :filtered_attribute
    alias_method :are_the_attributes,   :filtered_attribute

    # Gets all the defined attribute set names hashed by attribute names.
    # 
    # @note Use +key+ method explicitly to check if the given attribute is assigned to any set. The hash
    #  returned by this method will always return {AttributeSet} object. If the attribute is not assigned
    #  to any set then the returned, matching set will be empty.
    # 
    # @return [Hash{String => AttributeSet<Symbol>}] the collection of attribute set names indexed by attribute names
    def attributes_to_sets
      self.class.attributes_to_sets
    end
    alias_method :attribute_sets_map, :attributes_to_sets

    # This module contains class methods
    # that create DSL for managing attribute sets.
    module ClassMethods
      # @overload attribute_set()
      #   Gets all the defined attribute sets by calling +attribute_sets+.
      #   @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
      # 
      # @overload attribute_set(set_name)
      #   Gets the attribute set of the given name from internal storage.
      #   @param set_name [Symbol,String] name of a set
      #   @return [AttributeSet<String>] the attribute set
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
        case args.size
        when 0
          attribute_sets
        when 1
          first_arg = args.first
          if first_arg.is_a?(Hash) # multiple sets defined
            first_arg.each_pair { |k, v| attribute_set(k, v) }
            nil
          else
            attribute_sets[first_arg.to_sym]
          end
        else
          first_arg = args.shift
          if first_arg.is_a?(Hash) # multiple sets defined
            first_arg.each_pair do |k, v|
              attribute_set(k, v, args)
            end
          else                      # sinle set and optional attrs given
            AttributeFiltersHelpers.check_wanted_methods(self)
            add_atrs_to_set(first_arg.to_sym, *args)
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
              if set_name.is_a?(Hash) # annotation
                set_name.each_pair do |set_name_b, a_defs|
                  attribute_set(set_name_b, first_arg => a_defs)
                end
              else
                attribute_set(set_name, first_arg)
              end
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
      # 
      # @note Use +key+ method explicitly to check if the given set exists. The hash returned by this method
      #  will always return {AttributeSet} object. If there is no such set defined then the returned,
      #  matching set will be empty. All set objects are duplicates of the defined sets.
      # 
      # @return [Hash{Symbol => AttributeSet<String>}] the collection of attribute sets indexed by their names
      def attribute_sets
        d = Hash.new(ActiveModel::AttributeSet.new.freeze)
        __attribute_sets.each_pair do |set_name, set_object|
          d[set_name] = set_object.deep_dup
        end
        d
      end
      alias_method :attributes_sets, :attribute_sets
      alias_method :properties_sets, :attribute_sets

      # Gets all the defined attribute set names hashed by attribute names.
      # 
      # @note Use +key+ method explicitly to check if the given attribute is assigned to any set. The hash
      #  returned by this method will always return {AttributeSet} object. If the attribute is not assigned
      #  to any set then the returned, matching set will be empty.
      # 
      # @return [Hash{String => AttributeSet<Symbol>}] the collection of attribute set names indexed by attribute names
      def attributes_to_sets
        d = Hash.new(ActiveModel::AttributeSet.new.freeze)
        __attributes_to_sets_map.each_pair do |set_name, set_object|
          d[set_name] = set_object.deep_dup
        end
        d
      end
      alias_method :attribute_sets_map, :attributes_to_sets

      # @overload treat_as_real(*attributes)
      #   Informs Attribute Filters that the given attributes
      #   should be treated as present, even they are not in
      #   attributes hash provided by ORM or ActiveModel.
      #   Useful when operating on semi-virtual attributes.
      # 
      #   @note To operate on virtual attributes use +attr_virtual+ instead.
      #   
      #   @param attributes [Array] list of attribute names
      #   @return [void]
      # 
      # @overload treat_as_real()
      #   Gets the memorized attribute names that should be
      #   treated as existing.
      #   
      #   @return [AttributeSet] set of attribute names
      def treat_as_real(*args)
        return __attribute_filters_semi_real.deep_dup if args.blank?
        __attribute_filters_semi_real << args.flatten.compact.map { |atr| atr.to_s }
        nil
      end
      alias_method :attribute_filters_semi_real,  :treat_as_real
      alias_method :treat_attribute_as_real,      :treat_as_real
      alias_method :treat_attributes_as_real,     :treat_as_real

      # @overload attribute_filters_virtual(*attributes)
      #   Informs Attribute Filters that the given attributes
      #   should be treated as virtual (even not present in the
      #   attributes hash provided by ORM or ActiveModel).
      # 
      #   @param attributes [Array] list of attribute names
      #   @return [void]
      # 
      # @overload attribute_filters_virtual()
      #   Gets the memorized attribute names that should be
      #   treated as virtual.
      #   
      #   @return [AttributeSet] set of attribute names
      def treat_as_virtual(*args)
        return __attribute_filters_virtual.deep_dup if args.blank?
        __attribute_filters_virtual << args.flatten.compact.map { |atr| atr.to_s }
        nil
      end
      alias_method :attribute_filters_virtual, :treat_as_virtual
      alias_method :treat_attribute_as_virtual, :treat_as_virtual
      alias_method :treat_attributes_as_virtual, :treat_as_virtual

      private

      def __attribute_filters_semi_real
        @__attribute_filters_semi_real ||= ActiveModel::AttributeSet.new
      end

      def __attribute_filters_virtual
        @__attribute_filters_virtual ||= ActiveModel::AttributeSet.new
      end

      def __attributes_to_sets_map
        @__attributes_to_sets_map ||= Hash.new
      end

      def __attribute_sets
        @__attribute_sets ||= Hash.new
      end

      def add_atrs_to_set(set_name, *atrs)
        atrs = atrs.flatten.compact
        atrs.each do |atr_name|
          if atr_name.is_a?(Hash) # annotation
            atr_name.each_pair do |atr_name_b, a_defs|
              add_atrs_to_set(set_name, atr_name_b)
              s = __attribute_sets[set_name] and a_defs.nil? or a_defs.each_pair { |n, v| s.annotate(atr_name_b, n, v) }
            end
            return
          else
            atr_name = atr_name.to_s
            __attributes_to_sets_map[atr_name] ||= ActiveModel::AttributeSet.new
            __attributes_to_sets_map[atr_name] << set_name
          end
        end

        __attribute_sets[set_name] ||= ActiveModel::AttributeSet.new
        __attribute_sets[set_name] << atrs.map{ |a| a.to_s }.freeze
      end
    end # module ClassMethods
  end # module AttributeMethods
end # module ActiveModel
