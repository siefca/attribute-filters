# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains backports for compatibility with previous Ruby versions.

# @private
# @abstract This class is here for compatibility reasons.
class Object

  unless method_defined?(:public_send)
    # @private
    def public_send(name, *args)
      unless public_methods.include?(name.to_s)
        raise NoMethodError.new("undefined method `#{name}' for \"#{self.inspect}\":#{self.class}")
      end
      send(name, *args)
    end
  end

  unless method_defined?(:public_method)
    # @private
    def public_method(name)
      unless public_methods.include?(name.to_s)
        raise NameError.new("undefined method `#{name}' for class `#{self.class}'")
      end
      method(name)
    end
  end

end # class Object

# @private
# @abstract This class is here for compatibility reasons.
class Hash

  # @private
  unless method_defined?(:deep_merge)
    def deep_merge(o)
      dup.deep_merge!(o)
    end
  end

  # @private
  unless method_defined?(:deep_merge!)
    def deep_merge!(other_hash)
      other_hash.each_pair do |k, ov|
        my_v = self[k]
        self[k] = my_v.is_a?(Hash) && ov.is_a?(Hash) ? my_v.deep_merge(ov) : ov
      end
      self
    end
  end

  # @private
  unless method_defined?(:deep_dup)
    def deep_dup
      duplicate = self.dup
      duplicate.each_pair do |k, ov|
        my_v = duplicate[k]
        duplicate[k] = my_v.is_a?(Hash) && ov.is_a?(Hash) ? my_v.deep_dup : ov
      end
      duplicate
    end
  end

end # class Hash
