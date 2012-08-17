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
    # This module contains common, ready-to-use filtering methods.
    module Common

      # @private
      module CommonFilter
        # @private
        def included(base)
          if base == ActiveModel::AttributeFilters::Common
            base::ClassMethods.send(:include, self::ClassMethods)
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

      require 'attribute-filters/common_filters/strip'
      require 'attribute-filters/common_filters/case'
      require 'attribute-filters/common_filters/capitalize'
      require 'attribute-filters/common_filters/squeeze'
      require 'attribute-filters/common_filters/split'
      require 'attribute-filters/common_filters/join'

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
