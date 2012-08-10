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
    include ActiveModel::AttributeSet::Enumerable
    include ActiveModel::AttributeSet::Annotations

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

    # Merges the elements of the given enumerable
    # object to the attribute set and returns self.
    # 
    # @param o [Enumerable] object to be merged
    # @return [AttributeSet] current object
    def merge(o)
      r = super
      copy_annotations(o)
      r
    end

    # Copies internal structures.
    # 
    # @param o [AttributeSet] other set to copy from
    # @return [AttributeSet] current attribute set
    def initialize_copy(o)
      r = super
      remove_annotations
      copy_annotations(o)
      r
    end

    # Returns a new attribute set containing elements
    # common to the attribute set and the given enumerable object.
    # 
    # @param o [Enumerable] object to intersect with
    # @return [AttributeSet] intersection of objects
    def &(o)
      r = super
      if r.is_a?(self.class)
        r.send(:copy_annotations, self)
        r.send(:copy_annotations, o)
      end
      r
    end
    alias_method :intersection, :&

    # Deletes the given attribute name from the attribute set
    # and returns self.
    # 
    # @note Use subtract to delete many items at once.
    # @param o [Symbol,String] attribute name to delete from set
    # @return [AttributeSet] current attribute set
    def delete(o)
      o = o.to_s
      r = super
      r.nil? or delete_annotation(o)
      r
    end

    # Deletes every attribute of the attribute set
    # for which the given block evaluates to +true+,
    # and returns self.
    # 
    # @yield [o] block that controlls if an element should be deleted
    # @yieldparam o [String] current attribute
    # @return [AttributeSet] current attribute set
    def delete_if
      block_given? or return enum_for(__method__)
      super { |o| r = yield(o) and delete_annotation(o) ; r }
    end

    # Deletes every attribute of the attribute set
    # for which the given block evaluates to +false+,
    # and returns self.
    # 
    # @yield [o] block that controlls if an element should be kept
    # @yieldparam o [String] current attribute
    # @return [AttributeSet] current attribute set
    def keep_if
      block_given? or return enum_for(__method__)
      super { |o| r = yield(o) or delete_annotation(o) ; r }
    end

    # Returns a new attribute set containing elements
    # exclusive between the set and the given enumerable object
    # (exlusive disjuction).
    # 
    # @param o [Enumerable] object to exclusively disjunct with
    # @return [AttributeSet] resulting set
    def ^(o)
      n = self.class.new(o)
      n.remove_annotations
      each { |ob| if n.include?(ob) then n.delete(ob) else n.add(ob) end }
      n.send(:copy_annotations, self)
      n.send(:copy_annotations, o)
      n
    end
  end
end
