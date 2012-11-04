# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
#
# This file contains attr_virtual DSL method that sets up setter, getter,
# and enables change tracking for vitual attrbutes.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    module ClassMethods

      unless method_defined?(:method_added)
        def method_added(x); end
      end

      # @private
      def method_added_with_afv(method_name)
        method_name = method_name.to_s
        if method_name[-1] == '='
          atr_name = method_name[0..-2]
          have_writer = true
        else
          atr_name = method_name
          have_writer = false
        end
        a = __attribute_filters_virtual[atr_name]
        if a && a != :no_wrap
          if have_writer && method_defined?(atr_name) || !have_writer && method_defined?("#{atr_name}=")
            wrap_virtual_attribute_writer(atr_name)
          end
        end
        method_added_without_afv(method_name)
      end
      alias_method :method_added_without_afv, :method_added
      alias_method :method_added, :method_added_with_afv

      private

      def wrap_virtual_attribute_writer(atr_name)
        writer_name = "#{atr_name}=".to_sym
        writer_name_wct = "#{atr_name}_without_ct"
        __attribute_filters_virtual[atr_name] = false
        alias_method(writer_name_wct, writer_name)
        class_eval <<-EVAL
          def #{writer_name}(val)
            attribute_will_change!('#{atr_name}') if val != #{atr_name}
            #{writer_name_wct}(val)
          end
        EVAL
        __attribute_filters_virtual[atr_name] = :tracked
        nil
      end

      unless method_defined?(:attr_virtual)
        # This method creates setter and getter for attributes of the given names
        # and ensures that changes of their values are tracked.
        # 
        # @note Placing +attr_writer+ with the same attribute name AFTER
        #  +attr_virtual+ will overwrite setter. Don't do that.
        def attr_virtual(*attribute_names)
          attribute_names.flatten.compact.uniq.each do |atr_name|
            atr_name = atr_name.to_s
            writer_name = "#{atr_name}=".to_sym
            if method_defined?(writer_name) && method_defined?(atr_name)
              unless __attribute_filters_virtual.key?(atr_name)
                wrap_virtual_attribute_writer(atr_name)
              end
            else
              __attribute_filters_virtual[atr_name] = :waiting
            end
          end
          nil
        end # def attr_virtual
        alias_method :has_virtual_attribute, :attr_virtual
      end # unless method_defined?(:attr_virtual)

    end # module ClassMethods
  end # module AttributeFilters
end # module ActiveModel
