# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeSet::AttrQuery class
# used to interact with attribute sets containing set names.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  class AttributeSet
    # This class contains proxy methods used to interact with
    # AttributeSet instances. It's responsible for all of the DSL magic
    # that allows sweet constructs like:
    #   the_attribute(:x).is.in_set?
    class AttrQuery < Query
      # This is a proxy method that causes some calls to be
      # intercepted. Is allows to create semi-natural
      # syntax when querying attribute sets containing set names.
      # 
      # @example
      #   the_attribute(:some_attribute).is.in?(:some_set)
      #   the_attribute(:some_attribute).list.sets
      # 
      # @param method_sym [Symbol,String] name of method that will be queued or called on a set
      # @param args [Array] optional arguments to be passed to a method call
      # @yield optional block to be passed to a method call
      def method_missing(method_sym, *args, &block)
        case method_sym.to_sym
        when :are, :is, :in, :list, :show, :be, :should, :sets, :in_sets
          self
        when :in?, :in_set?, :in_a_set?, :in_the_set?, :the_set?, :set?
          args = args.map{|a|a.to_sym if a.respond_to?(:to_sym)} if args.is_a?(Array) && args.present?
          @set_object.include?(*args, &block)
        else
          @set_object.method(method_sym).call(*args, &block)
        end
      end
    end # class AttrQuery
  end # class AttributeSet
end # module ActiveModel
