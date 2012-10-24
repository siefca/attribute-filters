# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains modules with methods that create DSL for managing attribute filters.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # @private
    PROCESSING_FLAGS = {
      :process_blank      => false,
      :process_all        => false,
      :no_presence_check  => false,
      :include_missing    => false
    }.freeze

    # Gets names of attributes for which filters should be applied by
    # selecting attributes that are meeting certain criteria and belong
    # to the given attribute set.
    # 
    # @overload attributes_to_filter(set_name, process_all, no_presence_check)
    #   @param set_name [String,Symbol] name of a set of attributes used to get attributes
    #   @param process_all [Boolean] if set then all the attributes from the attribute set are selected,
    #     not just the attributes that have changed (defaults to +false+)
    #   @param no_presence_check [Boolean] if set then the checking whether each attribute exists will be
    #     disabled (matters only when +process_all+ is also set) (defaults to +false+)
    #   @return [AttributeSet] set of attributes (attribute name => previous_value)
    # 
    # @overload attributes_to_filter(attribute_set, process_all, no_presence_check)
    #   @param attribute_set [AttributeSet] set of attributes used to get attributes
    #   @param process_all [Boolean] if set then all the attributes from the attribute set are selected,
    #     not just the attributes that has changed (defaults to +false+)
    #   @param no_presence_check [Boolean] if set then the checking whether each attribute exists will be
    #     disabled (matters only when +process_all+ is also set) (defaults to +false+)
    #   @return [AttributeSet] set of attributes (attribute name => previous_value)
    def attributes_to_filter(set_name, process_all = false, no_presence_check = false)
      atf = set_name.is_a?(::ActiveModel::AttributeSet) ? set_name : attribute_set_simple(set_name)
      if process_all
        no_presence_check ? atf : atf & all_attributes(true, no_presence_check)
      else
        atf & (all_semi_real_attributes(true, no_presence_check) + changes.keys)
      end
    end

    # @overload filter_attrs_from_set(set_name, *flags, *args, &block)
    #   
    #   @note Combining the flags +process_all+ and +no_presence_check+ may raise
    #     exception if some attribute from the given set doesn't exist
    #   
    #   This generic method writes the result of execution of the passed block
    #   to each attribute that belongs to the given set of attributes.
    #   It's major purpose is to create filtering methods.
    #   
    #   Only the
    #   {http://rubydoc.info/gems/activemodel/ActiveModel/Dirty#changes-instance_method changed attributes/properties}
    #   are selected, unless the +process_all+ flag is
    #   given. If that flag is given then presence of each attribute is verified,
    #   unless the +no_presence_check+ flag is also set. Attributes with empty or unset values
    #   are ignored (but see the flag called +process_blank+).
    #   
    #   The result of the given block is used to set a new values for processed attributes. 
    #   
    #   @param set_name [Symbol] name of the attribute set or a set object
    #   @param args [Array] optional additional arguments that will be passed to the block
    #   @param flags [Array<Symbol>] optional additional flags controlling the processing of attributes:
    #     * +:process_blank+ – tells to also process attributes that are blank (empty or +nil+)
    #     * +:process_all+ - tells to process all attributes, not just the ones that has changed
    #     * +:no_presence_check+ – tells not to check for existence of each processed attribute when processing
    #       all attributes; increases performance but you must care about putting only the existing attributes into sets
    #   @yield [attribute_value, set_name, attribute_name, *args] block that will be called for each attribute
    #   @yieldparam attribute_value [Object] current attribute value that should be altered
    #   @yieldparam attribute_name [String] a name of currently processed attribute
    #   @yieldparam set_object [Object] currently processed set that attribute belongs to
    #   @yieldparam set_name [Symbol] a name of the processed attribute set
    #   @yieldparam args [Array] optional arguments passed to the method
    #   @yieldreturn [Object] the result of calling the block 
    #   @return [void]
    #   
    #   @example
    #     class User < ActiveRecord::Base
    #       
    #       attributes_that should_be_downcased: [ :username, :email ]
    #       before_filter :downcase_names
    #       
    #       def downcase_names
    #         filter_attributes_that :should_be_downcased do |atr|
    #           atr.mb_chars.downcase.to_s
    #         end
    #       end
    #     
    #     end
    def filter_attrs_from_set(set_name, *args, &block)
      operate_on_attrs_from_set(set_name, true, *args, &block)
    end
    alias_method :attribute_filter_for_set,     :filter_attrs_from_set
    alias_method :filter_attributes_which,      :filter_attrs_from_set
    alias_method :filter_attributes_that,       :filter_attrs_from_set
    alias_method :filter_attributes_that_are,   :filter_attrs_from_set
    alias_method :filter_attributes_which_are,  :filter_attrs_from_set
    alias_method :alter_attributes_which,       :filter_attrs_from_set
    alias_method :alter_attributes_that,        :filter_attrs_from_set
    alias_method :alter_attributes_that_are,    :filter_attrs_from_set
    alias_method :alter_attributes_which_are,   :filter_attrs_from_set

    # @overload for_each_attr_from_set(set_name, *flags, *args, &block)
    #   
    #   @note If you're looking for a method that is designed to alter attributes
    #     by rewritting their contents see {#filter_attrs_from_set}
    # 
    #   @note Combining the flags +process_all+ and +no_presence_check+ may raise
    #     exception if some attribute from the given set doesn't exist
    # 
    #   This generic method calls the passed block for each attribute
    #   that belongs to the given set of attributes.
    #   It's major purpose is to iterate through attributes and/or work directly with their values.
    #   
    #   Only the
    #   {http://rubydoc.info/gems/activemodel/ActiveModel/Dirty#changes-instance_method changed attributes/properties}
    #   are selected, unless the +process_all+ flag is
    #   given. If that flag is given then presence of each attribute is verified,
    #   unless the +no_presence_check+ flag is also set. Attributes with
    #   empty or unset values are ignored (but see the flag called +process_blank+).
    #   
    #   The result of the given block is not used to set the processed attribute.
    #   The only way to alter attribute values using this method is to use bang
    #   method in a block or explicitly assign new, calculated value to the attribute
    #   using its name (also passed to a block as one of arguments).
    #   
    #   @param set_name [Symbol] name of the attribute set or a set object
    #   @param args [Array] optional additional arguments that will be passed to a block
    #   @param flags [Array<Symbol>] optional additional flags controlling the processing of attributes:
    #     * +:process_blank+ – tells to also process attributes that are blank (empty or +nil+)
    #     * +:process_all+ - tells to process all attributes, not just the ones that has changed
    #     * +:no_presence_check+ – tells not to check for existence of each processed attribute when processing
    #       all attributes; increases performance but you must care about putting into set only the existing attributes
    #     * +:include_missing+ – includes attributes that does not exist in a resulting iteration (their values are
    #       always +nil+); has the effect only when +process_blank+ and +no_presence_check+ are set
    #   @yield [attribute_value, set_name, attribute_name, *args] block that will be called for each attribute
    #   @yieldparam attribute_value [Object] current attribute value that should be altered
    #   @yieldparam attribute_name [String] a name of currently processed attribute
    #   @yieldparam set_object [Object] currently processed set that attribute belongs to
    #   @yieldparam set_name [Symbol] a name of the processed attribute set
    #   @yieldparam args [Array] optional arguments passed to the method
    #   @yieldreturn [Object] the result of calling the block 
    #   @return [void]
    #   
    #   @example
    #     class User < ActiveRecord::Base
    #     
    #       attributes_that should_be_stripped: [ :username, :email ]
    #       before_filter :strip_names
    #       
    #       def strip_names
    #         for_attributes_that :should_be_stripped do |atr|
    #           atr.strip!
    #         end
    #       end
    #     
    #     end
    def for_each_attr_from_set(set_name, *args, &block)
      operate_on_attrs_from_set(set_name, false, *args, &block)
    end
    alias_method :attribute_call_for_set,   :for_each_attr_from_set
    alias_method :call_attrs_from_set,      :for_each_attr_from_set
    alias_method :for_attributes_which,     :for_each_attr_from_set
    alias_method :for_attributes_that,      :for_each_attr_from_set
    alias_method :for_attributes_that_are,  :for_each_attr_from_set
    alias_method :for_attributes_which_are, :for_each_attr_from_set

    private

    # Applies operations to elements from set.
    def operate_on_attrs_from_set(set_name, alter_mode, *args, &block)
      block_given? or return enum_for(__method__, set_name, alter_mode, *args)
      flags             = AttributeFiltersHelpers.process_flags(args)
      process_all       = flags[:process_all]
      process_blank     = flags[:process_blank]
      no_presence_check = flags[:no_presence_check]
      include_missing   = flags[:include_missing]
      if set_name.is_a?(::ActiveModel::AttributeSet)
        set_obj = set_name
        set_name = nil
      else
        set_obj = attribute_set_simple(set_name)
      end
      attrs_to_process = attributes_to_filter(set_obj, process_all, no_presence_check)
      if alter_mode
        if process_blank
          # filtering without testing for blank
          attrs_to_process.each do |atr|
            public_send("#{atr}=", yield(public_send(atr), atr, set_obj, set_name, *args))
          end
        else
          # filtering present only
          attrs_to_process.each do |atr|
            v = public_send(atr)
            public_send("#{atr}=", yield(v, atr, set_obj, set_name, *args)) if v.present?
          end
        end
      else
        if process_blank
          # calling without testing for blank
          if include_missing
            # including missing attributes (changing them into nils)
            attrs_to_process.each do |atr|
              v = respond_to?(atr) ? public_send(atr) : nil
              yield(v, atr, set_obj, set_name, *args)
            end
          else
            attrs_to_process.each do |atr|
              yield(public_send(atr), atr, set_obj, set_name, *args)
            end
          end
        else
          # calling present only
          attrs_to_process.each do |atr|
            v = public_send(atr)
            yield(v, atr, set_obj, set_name, *args) if v.present?
          end
        end
      end
    end
  end # module AttributeFilters
end # module ActiveModel
