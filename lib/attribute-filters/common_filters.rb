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

    # This method is a callback method that tries to call all
    # known filtering methods if they are present.
    # 
    # Calling order:
    # * split_attributes
    # * join_attributes
    # * squeeze_attributes
    # * strip_attributes
    # * upcase_attributes
    # * downcase_attributes
    # * capitalize_attributes
    # * fully_capitalize_attributes
    # * titleize_attributes
    def filter_attributes
      respond_to?(:split_attributes)            and split_attributes
      respond_to?(:join_attributes)             and join_attributes
      respond_to?(:convert_attributes)          and convert_attributes
      respond_to?(:squeeze_attributes)          and squeeze_attributes
      respond_to?(:strip_attributes)            and strip_attributes
      respond_to?(:upcase_attributes)           and upcase_attributes
      respond_to?(:downcase_attributes)         and downcase_attributes
      respond_to?(:capitalize_attributes)       and capitalize_attributes
      respond_to?(:fully_capitalize_attributes) and fully_capitalize_attributes
      respond_to?(:titleize_attributes)         and titleize_attributes
      respond_to?(:fill_attributes)             and fill_attributes
    end

    # This module contains common, ready-to-use filtering methods.
    module Common

      # @private
      module CommonFilter
        # @private
        def included(base)
          if  base.const_defined?(:ClassMethods)  &&
              base.instance_of?(::Module)         &&
              base.const_get(:ClassMethods).instance_of?(::Module)
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
            base.extend ClassMethods
          end
        end
      end

      extend CommonFilter

      # This module contains class methods used by the DSL
      # to create keywords for common operations.
      module ClassMethods
      end

      # Include all default filters
      # that should be available
      # when Common module is included.
      Dir[File.join(File.dirname(__FILE__), 'common_filters', '*.rb')].each do |f|
        require f
      end

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
