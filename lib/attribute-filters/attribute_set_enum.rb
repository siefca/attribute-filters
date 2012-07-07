# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains AttributeSetEnumerable module and AttributeSetEnumerator class.

# This module adds some enumerable properties to AttributeSet objects.
module AttributeSetEnumerable
  # @private
  def select
    if block_given?
      ActiveModel::AttributeSet.new.tap do |r|
        each { |e| r << e if yield(e) }
      end
    else
      AttributeSetEnumerator.new(self, :select)
    end
  end

  # @private
  def reject
    if block_given?
      ActiveModel::AttributeSet.new.tap do |r|
        each { |e| r << e unless yield(e) }
      end
    else
      AttributeSetEnumerator.new(self, :reject)
    end
  end

  # @private
  def collect
    if block_given?
      ActiveModel::AttributeSet.new.tap do |r|
        each { |e| r << yield(e) }
      end
    else
      AttributeSetEnumerator.new(self, :map)
    end
  end
  alias_method :map, :collect

  # @private
  def sort
    ActiveModel::AttributeSet.new(super)
  end

  # @private
  def sort_by
    ActiveModel::AttributeSet.new(super)
  end
end

# This class adds enumerator for AttributeSet elements.
class AttributeSetEnumerator < ::Enumerator
  include AttributeSetEnumerable
end

