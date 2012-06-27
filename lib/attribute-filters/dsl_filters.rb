# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains modules with methods that create DSL for managing attribute filters.

module ActiveModel
  module AttributeFilters
    # Gets names of attributes for which filters should be applied by
    # selecting attributes that 1. have changed and 2. their names belong to
    # the given set of attributes.
    # 
    # @param process_unchanged [Boolean] if set to +true+ then all accessible attributes will
    #  be tested (which are also present in set o course), not just the changed ones
    # @param set_name [AttributeSet] set of attributes used to select attributes
    # @return [Hash{Symbol => Object}] list of attributes (attribute name => previous_value)
    def attributes_to_filter(set_name, process_unchanged = false)
      @__attr_op_apply ||= Array.new
      if process_unchanged
        @__attr_op_apply[0] ||= Hash.new
        @__attr_op_apply[0][set_name] || begin
          buf = @__attr_op_apply[0][set_name] = Hash.new
          (attribute_set(set_name) & self.class.accessible_attributes.to_a).each do |a|
            buf[a] = nil
          end
          buf
        end
      else
        @__attr_op_apply[1] ||= Hash.new
        @__attr_op_apply[1][set_name] ||= changed_attributes.select do |a,pv|
          attribute_set(set_name).include?(a)
        end
      end
    end

    # This generic method applies a result of execution of the passed block
    # to each of all changed attributes that are present in the given
    # set of attributes. It is useful in creating filtering methods.
    # The result of a block is used to set a new value for each processed attribute.
    # 
    # @param set_name [Symbol] name of the attributes set
    # @param args [Array] optional additional arguments that will be passed to the block
    # @yield [attribute_value, previous_value, set_name, attribute_name, *args] block that will be called for each attribute
    # @yieldparam attribute_value [Object] current attribute value that should be altered
    # @yieldparam previous_value [Object] the value of an attribute before change was made by ORM
    # @yieldparam set_name [Symbol] a name of the processed attribute set
    # @yieldparam attribute_name [Object] a name of currently processed attribute
    # @yieldparam args [Array] optional arguments passed to the method
    # @yieldreturn [Object] the result of calling the block 
    # @return [void]
    # 
    # @example
    #   class User < ActiveRecord::Base
    #     
    #     attributes_that :should_be_downcased => [ :username, :email ]
    #     before_filter :downcase_names
    #     
    #     def downcase_names
    #       filter_attributes_that :should_be_downcased do |atr|
    #         atr.mb_chars.downcase.to_s
    #       end
    #     end
    #   
    #   end
    def filter_attrs_from_set(set_name, *args, &block)
      flags = attr_filter_process_flags(args)
      pb = flags[:process_blank]
      pu = flags[:process_unchanged]
      attributes_to_filter(set_name, pu).each do |a, pv|
        v = self[a]
        pv = v if pu
        self[a] = yield(v, pv, set_name, a, *args) if (pb || v.present?)
      end
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

    # This generic method calls the passed block
    # on each of all changed attributes that are present in the given
    # set of attributes. It is useful in creating filtering methods.
    # The result of a block is ignored, so the only effective way of
    # altering attribute values is calling altering method on attributes
    # (usually with bang methods).
    # 
    # @param set_name [Symbol] name of the attributes set
    # @param args [Array] optional additional arguments that will be passed to the block
    # @yield [attribute_value, previous_value, set_name, attribute_name, *args] block that will be called for each attribute
    # @yieldparam attribute_value [Object] current attribute value that should be altered
    # @yieldparam previous_value [Object] the value of an attribute before change was made by ORM
    # @yieldparam set_name [Symbol] a name of the processed attribute set
    # @yieldparam attribute_name [Object] a name of currently processed attribute
    # @yieldparam args [Array] optional arguments passed to the method
    # @yieldreturn [void]
    # @return [void]
    # 
    # @example
    #   class User < ActiveRecord::Base
    #   
    #     attributes_that :should_be_stripped => [ :username, :email ]
    #     before_filter :strip_names
    #     
    #     def strip_names
    #       for_attributes_that :should_be_stripped do |atr|
    #         atr.strip!
    #       end
    #     end
    #   
    #   end
    def call_attrs_from_set(set_name, *args, &block)
      flags = attr_filter_process_flags(args)
      pb = flags[:process_blank]
      pu = flags[:process_unchanged]
      attributes_to_filter(set_name, pu).each do |a, pv|
        v = self[a]
        pv = v if pu
        yield(v, pv, set_name, a, *args) if (pb || v.present?)
      end
    end
    alias_method :attribute_call_for_set,   :call_attrs_from_set
    alias_method :for_attributes_which,     :call_attrs_from_set
    alias_method :for_attributes_that,      :call_attrs_from_set
    alias_method :for_attributes_that_are,  :call_attrs_from_set
    alias_method :for_attributes_which_are, :call_attrs_from_set

    private

    def attr_filter_process_flags(args)
      flags = { :process_blank => false, :process_unchanged => false }
      while flags.key?(a=args[0]) do
        flags[a] = !!args.shift
      end
      flags
    end

  end
end
