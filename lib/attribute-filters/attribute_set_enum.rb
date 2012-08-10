# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains AttributeSet::Enumerable module and AttributeSet::Enumerator class.

require 'set'

# This module adds some enumerable properties to AttributeSet objects.
module ActiveModel
  class AttributeSet < ::Set
    module Enumerable
      # @private
      def select
        if block_given?
          ActiveModel::AttributeSet.new.tap do |r|
            each { |e| r << e if yield(e) }
          end
        else
          AttributeSet::Enumerator.new(self, :select)
        end
      end

      # @private
      def reject
        if block_given?
          ActiveModel::AttributeSet.new.tap do |r|
            each { |e| r << e unless yield(e) }
          end
        else
          AttributeSet::Enumerator.new(self, :reject)
        end
      end

      # @private
      def collect
        if block_given?
          ActiveModel::AttributeSet.new.tap do |r|
            each { |e| r << yield(e) }
          end
        else
          AttributeSet::Enumerator.new(self, :map)
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

      # @private
      def each
        if block_given?
            super
        else
          AttributeSet::Enumerator.new(self, :each)
        end
      end
    end # module Enumerable

    # This class adds enumerator for AttributeSet elements.
    class Enumerator < ::Enumerator
      include ActiveModel::AttributeSet::Enumerable
    end # class Enumerator

  end # class AttributeSet
end # module ActiveModel

# @abstract This module is here for compatibility reasons.
module AttributeSetEnumerable
  include ActiveModel::AttributeSet::Enumerable
end

# @abstract This class is here for compatibility reasons.
class AttributeSetEnumerator < ActiveModel::AttributeSet::Enumerator
  include AttributeSetEnumerable
end
