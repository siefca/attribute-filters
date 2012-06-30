# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains modules with methods that create DSL for managing attribute filters.

module ActiveModel
  module AttributeFilters
    # @private
    PROCESSING_FLAGS = {
      :process_blank      => false,
      :process_all        => false,
      :no_presence_check  => false
    }.freeze

    # Gets names of attributes for which filters should be applied by
    # selecting attributes that are meeting certain criteria and belong
    # to the given attribute set.
    # 
    # @param set_name [AttributeSet] set of attributes used to get attributes
    # @param alter_mode [Boolean] if set then the existence
    #   of attribute is checked by testing if writer is defined; otherwise the reader is checked
    # @param process_all [Boolean] if set then all the attributes from the attribute set are selected,
    #   not just attributes that has changed
    # @param no_presence_check [Boolean] if set then the checking whether attribute exists will be
    #   disabled (matters only when +process_all+ is also set
    # @return [AttributeSet] set of attributes (attribute name => previous_value)
    def attributes_to_filter(set_name, process_all = false, no_presence_check = false)
      atf = attribute_set(set_name)
      if process_all
        no_presence_check ? atf : atf & attributes.keys
      else
        atf & changed_attributes.keys
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
    #   {http://rubydoc.info/gems/activemodel/ActiveModel/Dirty#changed_attributes-instance_method changed attributes}
    #   are selected, unless the +process_all+ flag is
    #   given. If that flag is given then presence of each attribute is verified,
    #   unless the +no_presence_check+ flag is also set. Attributes with empty or unset values
    #   are ignored (but see the flag called +process_blank+).
    #   
    #   The result of the given block is used to set a new values for processed attributes. 
    #   
    #   @param set_name [Symbol] name of the attribute set
    #   @param args [Array] optional additional arguments that will be passed to the block
    #   @param flags [Array<Symbol>] optional additional flags controlling the processing of attributes:
    #     * +:process_blank+ – tells to also process attributes that are blank (empty or +nil+)
    #     * +:process_all+ - tells to process all attributes, not just the ones that has changed
    #     * +:no_presence_check+ – tells not to check for existence of each processed attribute when processing
    #       all attributes; increases performance but you must care about putting into set only the existing attributes
    #   @yield [attribute_value, set_name, attribute_name, *args] block that will be called for each attribute
    #   @yieldparam attribute_value [Object] current attribute value that should be altered
    #   @yieldparam set_name [Symbol] a name of the processed attribute set
    #   @yieldparam attribute_name [Object] a name of currently processed attribute
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
    #   {http://rubydoc.info/gems/activemodel/ActiveModel/Dirty#changed_attributes-instance_method changed attributes}
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
    #   @param set_name [Symbol] name of the attribute set
    #   @param args [Array] optional additional arguments that will be passed to a block
    #   @param flags [Array<Symbol>] optional additional flags controlling the processing of attributes:
    #     * +:process_blank+ – tells to also process attributes that are blank (empty or +nil+)
    #     * +:process_all+ - tells to process all attributes, not just the ones that has changed
    #     * +:no_presence_check+ – tells not to check for existence of each processed attribute when processing
    #       all attributes; increases performance but you must care about putting into set only the existing attributes
    #   @yield [attribute_value, set_name, attribute_name, *args] block that will be called for each attribute
    #   @yieldparam attribute_value [Object] current attribute value that should be altered
    #   @yieldparam set_name [Symbol] a name of the processed attribute set
    #   @yieldparam attribute_name [Object] a name of currently processed attribute
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

    def operate_on_attrs_from_set(set_name, alter_mode, *args, &block)
      flags             = AttributeFiltersHelpers.process_flags(args)
      process_all       = flags[:process_all]
      process_blank     = flags[:process_blank]
      no_presence_check = flags[:no_presence_check]
      attrs_to_process  = attributes_to_filter(set_name, process_all, no_presence_check)
      if alter_mode
        if process_blank
          # filtering without testing for blank
          attrs_to_process.each do |atr|
            send("#{atr}=", yield(send(atr), set_name, atr, *args))
          end
        else
          # filtering present only
          attrs_to_process.each do |atr|
            v = send(atr)
            send("#{atr}=", yield(v, set_name, atr, *args)) if v.present?
          end
        end
      else
        if process_blank
          # calling without testing for blank
          attrs_to_process.each do |atr|
            yield(send(atr), set_name, atr, *args)
          end
        else
          # calling present only
          attrs_to_process.each do |atr|
            v = send(atr)
            yield(v, set_name, atr, *args) if v.present?
          end
        end
      end
    end

  end # module AttributeFilters
end # module ActiveModel
