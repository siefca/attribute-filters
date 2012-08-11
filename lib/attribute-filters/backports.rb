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
