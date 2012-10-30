# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Strip module
# containing ready-to-use filtering method.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common
      # Strips attributes from leading and trailing spaces.
      module Strip
        extend CommonFilter
        # Strips attributes from leading and trailing spaces.
        # 
        # The attrubutes to be stripped are taken from the attribute set called
        # +should_be_stripped+. It operates directly on attribute's contents.
        # 
        # @note If a value of currently processed attribute is an array
        #  then any element of the array is changed. The same with hash (its values are changed).
        # 
        # @return [void]
        def strip_attributes
          filter_attrs_from_set(:should_be_stripped) do |atr|
            AFHelpers.each_element(atr, String) { |v| v.strip }
          end
        end
        filtering_method :strip_attributes, :should_be_stripped

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be stripped.
          def strip_attributes(*args)
            attributes_that(:should_be_stripped, args)
          end
          alias_method :strip_attribute, :strip_attributes
        end # module ClassMethods
      end # module Strip

      include Strip

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
