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
      unless method_defined?(:attr_virtual)
        # This method creates setter and getter for attributes of the given names
        # and ensures that changes of their values are tracked.
        # 
        # @note Placing +attr_writer+ with the same attribute name AFTER
        #  +attr_virtual+ will overwrite setter. Don't do that.
        def attr_virtual(*attribute_names)
          attribute_names.flatten.compact.uniq.each do |atr_name|
            writer_name = "#{atr_name}="
            atr_name = atr_name.to_sym
            attr_reader(atr_name) unless method_defined?(atr_name)
            attr_accessible(atr_name) if method_defined?(:attr_accessible)
            if method_defined?(writer_name)
              self.class_eval <<-EVAL
                alias_method :#{atr_name}_without_change_tracking=, :#{writer_name}
                def #{writer_name}(val)
                  attribute_will_change!('#{atr_name}') if val != #{'atr_name'}
                  #{atr_name}_without_change_tracking=(val)
                end
              EVAL
            else
              self.class_eval <<-EVAL
                def #{writer_name}(val)
                  attribute_will_change!('#{atr_name}') if val != '#{atr_name}'
                  @#{atr_name} = val
                end
              EVAL
            end
          end
        end # def attr_virtual
      end # unless method_defined?(:attr_virtual)
    end # module ClassMethods
  end # module AttributeFilters
end # module ActiveModel
