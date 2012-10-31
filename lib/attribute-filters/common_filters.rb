# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common module
# containing ready-to-use, common filtering methods.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters

    # This module holds method for marking methods as filters.
    module FilteringRegistration
      # This method marks a method as filtering method
      # and associates it with the given name of an attribute set it uses.
      # 
      # @param method_name [Symbol] name of a method
      # @param set_name [Symbol] name of an attribute set
      # @return [void]
      def filtering_method(method_name, set_name)
        set_name = set_name.to_sym
        return unless method_defined?(method_name)
        f = (@__filtering_sets ||= MetaSet.new)
        f[set_name] = method_name unless f.key?(set_name)
      end
    end

    # This module contains common, ready-to-use filtering methods.
    module Common
      # @private
      module CommonFilter
        include FilteringRegistration

        # @private
        def included(base)

          # merge filtering sets from filtering modules to models
          fs = @__filtering_sets
          unless fs.nil?
            base.class_eval do
              @__filtering_sets ||= MetaSet.new
              @__filtering_sets.merge!(fs)
            end
          end

          if  base.const_defined?(:ClassMethods)  &&
              base.instance_of?(::Module)         &&
              base.const_get(:ClassMethods).instance_of?(::Module)

            # If we're here then this module was included by some other module
            # (one of our own filtering submodules).
            base.class_eval <<-EVAL
              unless singleton_class.method_defined?(:included)
                def self.included(base)
                  base.extend ClassMethods
                end
              end
              module ClassMethods
                include #{self.name}::ClassMethods
              end
            EVAL

          else

            # If we're here then this module was included
            # by some model or other class.
            base.extend ClassMethods

          end
        end
      end # module CommonFilter

      # This module contains class methods used by the DSL
      # to create keywords for common filtering operations.
      # These keywords can be used in filtering submodules
      # and in any model that includes them.
      module ClassMethods
      end

      extend CommonFilter

      # Include all default filters
      # that should be available
      # when Common module is included.
      Dir[File.join(File.dirname(__FILE__), 'common_filters', '*.rb')].each do |f|
        require f
      end

    end # module Common

    # This method is a callback method that tries to call all
    # known filtering methods if they are in use.
    # 
    # Calling order depends on registering order.
    def filter_attributes
      as, fs = *self.class.class_eval { [__attribute_sets, @__filtering_sets] }
      return if fs.blank? || as.blank?
      as.each_pair { |set_name, o| send(fs[set_name]) if fs.has_key?(set_name) }
    end

    # Gets a list of filtering hooks that are in use.
    # 
    # @return [Hash{Symbol => Symbol}] a hash of filtering methods and associated sets
    def filtering_methods
      f = self.class.instance_variable_get(:@__filtering_sets)
      f.nil? ? ActiveModel::MetaSet.new : f.dup
    end

    module ClassMethods
      include FilteringRegistration
    end

  end # module AttributeFilters
end # module ActiveModel
