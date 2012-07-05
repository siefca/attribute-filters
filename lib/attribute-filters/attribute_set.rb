# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeSet class
# used to interact with attribute sets.

require 'set'

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  # This class is a data structure used to store
  # set of attributes.
  class AttributeSet < ::Set

    # Adds the given object to the set and returns self.
    # If the object is already in the set, returns nil.
    # If the object is an array it adds each element of the array.
    # The array is not flattened so if it contains other arrays
    # then they will be added as the arrays.
    # When adding an array the returning value is also an array,
    # which contains elements that were successfuly added to set
    # and didn't existed there before.
    # 
    # @param o [Object,Array] object to be added to set or array of objects
    # @return [AttributeSet,nil]
    def add(o)
      if o.is_a?(Array)
        o.map{ |e| super(e) }.compact
      else
        super
      end
    end
    alias_method :<<, :add

  end
end
