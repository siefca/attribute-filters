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
      def select
        block_given? ? super : AttributeSet::Enumerator.new(self, :select)
      end

      # @private
      def reject
        block_given? ? super : AttributeSet::Enumerator.new(self, :reject)
      end

      # @private
      def collect
        if block_given?
          super { |k, v| yield(k) }
        else
          AttributeSet::Enumerator.new(self, :map)
        end
      end
      alias_method :map, :collect

      # @private
      def each
        if block_given?
          super { |k, v| yield(k) }
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
