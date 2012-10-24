# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeSet class
# used to interact with attribute sets.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  # This class is a data structure used to store
  # set of attributes.
  class AttributeSet <  Hash
    include ActiveModel::AttributeSet::Enumerable
    include ActiveModel::AttributeSet::Annotations

    # Creates a new instance of attribute set.
    # 
    # @return [AttributeSet] an AttributeSet object
    def initialize(*args)
      return super if args.count == 0
      r = super()
      add(args)
      r
    end

    # Adds the given object to the set and returns self.
    # If the object is already in the set, returns nil.
    # If the object is an array it adds each element of the array.
    # The array is not flattened so if it contains other arrays
    # then they will be added as the arrays.
    # When adding an array the returning value is also an array,
    # which contains elements that were successfuly added to set
    # and didn't existed there before.
    # 
    # @param args [Array<Object,Hash,Array,Enumerable>] object(s) to be added to set
    # @return [AttributeSet,nil]
    def add(*args)
      args.flatten.each do |a|
        if a.is_a?(Hash)
          deep_merge!(a)
        elsif a.is_a?(::Enumerable)
          a.each { |e| self[e] = true unless e.blank? }
        else
          self[a] = true
        end
      end
    end
    alias_method :<<, :add

    # @private
    def to_a
      keys
    end

    # Adds two sets by deeply merging their contents.
    # If any value stored in one set under conflicting key
    # is +true+, +false+ or +nil+ then value is taken from other set.
    # If one of the conflicting values is a kind of Hash and
    # the other is not the it's converted to a hash which is merged in.
    # Otherwise the left value wins.
    # 
    # @return [AttributeSet] resulting set
    def +(o)
      my_class = self.class
      o = my_class.new(o) unless o.is_a?(Hash)
      r = my_class.new
      (keys + o.keys).uniq.each do |k|
        if self.key?(k) && o.key?(k)
          r[k] = merge_set(self[k], o[k]) { |a, b| a + b }
        else
          r[k] = safe_dup(self[k] || o[k])
        end
      end
      r
    end

    # Subtracts the given set from the current one
    # by removing all the elements that have the same keys.
    # 
    # @return [AttributeSet] resulting set
    def -(o)
      o = self.class.new(o) unless o.is_a?(Hash)
      reject { |k, v| o.include?(k) }
    end

    # Returns a new attribute set containing elements
    # common to the attribute set and the given enumerable object.
    # Annotations from other set that aren't in this set are copied.
    # 
    # @param o [Enumerable] object to intersect with
    # @return [AttributeSet] intersection of objects
    def &(o)
      my_class = self.class
      o = my_class.new(o) unless o.is_a?(Hash)
      r = my_class.new
      each_pair do |k, my_v|
        if o.include?(k)
          r[k] = merge_set(my_v, o[k]) { |a, b| a & b }
        end
      end
      r
    end
    alias_method :intersection, :&
    alias_method :intersect, :&

    # Returns a new attribute set containing elements
    # exclusive between the set and the given enumerable object
    # (exclusive disjuction).
    # 
    # @param o [Enumerable] object to exclusively disjunct with
    # @return [AttributeSet] resulting set
    def ^(o)
      my_class = self.class
      o = my_class.new(o) unless o.is_a?(Hash)
      r = my_class.new
      (o.keys + keys).uniq.each do |k|
        if key?(k)
          if !o.key?(k)
            src = self[k]
          else
            next
          end
        elsif o.key?(k)
          src = o[k]
        end
        r[k] = safe_dup(src)
      end
      r
    end

    private

    def safe_dup(src)
      src.respond_to?(:deep_dup) ? src.deep_dup : (src.is_a?(Enumerable) ? src.dup : src)
    end

    # Internal method for merging sets.
    def merge_set(my_v, ov, my_class = self.class)
      if my_v.is_a?(Hash)
        if ov.is_a?(Hash)
          my_v = my_class.new(my_v) unless my_v.is_a?(my_class)
          ov = my_class.new(ov) unless ov.is_a?(my_class)
          return yield(my_v, ov)
        else
          a_hash = my_v
          a_other = ov
        end
      else
        if ov.is_a?(Hash)
          a_hash = ov
          a_other = my_v
        else
          return my_v === true ? ov : my_v
        end
      end
      if a_other === true || a_other === false || a_other.nil?
        a_hash
      else
        a_hash.deep_merge(my_class.new(ov))
      end
    end
  end # module AttributeSet
end # module ActiveModel
