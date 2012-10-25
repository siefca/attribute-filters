# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains AttributeSet::Enumerable module and AttributeSet::Enumerator class.

# This module adds some enumerable properties to AttributeSet objects.
module ActiveModel
  class AttributeSet < Hash
    module Enumerable
      # @private
      def select(&block)
        block_given? or return AttributeSet::Enumerator.new(self, :select)
        ActiveModel::AttributeSet.new.tap { |r| each_pair { |k, v| r[k] = v if yield(k, v) } }
      end

      # Selects attributes that have setters and getters.
      # @param binding [Object] optional object which should have setters and getters (default: the calling context)
      # @return [AttributeSet::Enumerator, AttributeSet] resulting set or an enumerator if block is not given
      def select_accessible(binding = nil)
        if binding.nil?
          select { |a| respond_to?(a) && respond_to?("#{a}=") }
        else
          select { |a| binding.respond_to?(a) && binding.respond_to?("#{a}=") }
        end
      end

      # @private
      def reject
        block_given? or return AttributeSet::Enumerator.new(self, :reject)
        ActiveModel::AttributeSet.new.tap { |r| each_pair { |k, v| r[k] = v unless yield(k, v) } }
      end

      # @private
      def collect
        block_given? ? super { |k, v| yield(k) } : AttributeSet::Enumerator.new(self, :map)
      end
      alias_method :map, :collect

      # @private
      def each
        block_given? ? each_pair { |k, v| yield(k, v) } : AttributeSet::Enumerator.new(self, :each)
      end

      # @private
      def each_pair
        block_given? ? super : AttributeSet::Enumerator.new(self, :each_pair)
      end

      # @private
      def sort
        ActiveModel::AttributeSet[super]
      end

      # @private
      def sort_by
        block_given? ? ActiveModel::AttributeSet[super] : AttributeSet::Enumerator.new(self, :sort_by)
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
