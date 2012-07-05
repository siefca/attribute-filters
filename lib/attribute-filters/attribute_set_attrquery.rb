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
      # When the called method name ends with question mark then
      # its name is considered to be an attribute set name that
      # should be tested for presence of the attribute. To use
      # that syntax you must be sure that there is no already
      # defined method for AttributeSet object which name ends
      # with question mark. Otherwise you may get false positives
      # or a strange errors when trying to test if attribute belongs
      # to set. The real method call will override your check.
      # 
      # @example
      #   the_attribute(:some_attribute).is.in?(:some_set)
      #   the_attribute(:some_attribute).list.sets
      #   the_attribute(:some_attribute).is.in.a.set.that?(:should_be_downcased)
      #   the_attribute(:some_attribute).should_be_downcased?
      # 
      # @param method_sym [Symbol,String] name of method that will be queued or called on a set
      # @param args [Array] optional arguments to be passed to a method call
      # @yield optional block to be passed to a method call
      def method_missing(method_sym, *args, &block)
        case method_sym.to_sym
        when :are, :is, :one, :is_one, :in, :list, :show, :be, :should,
             :the, :a, :sets, :in_sets, :set, :in_a_set, :in_set, :belongs_to
          self
        when :belongs_to?, :in?, :in_set?, :in_a_set?, :in_the_set?,
             :the_set?, :set?, :is_one_that?, :one_that?, :that?
          if args.present? && args.is_a?(::Array)
            args = args.map{ |a| a.to_sym if a.respond_to?(:to_sym) }
          end
          @set_object.include?(*args, &block)
        else
          set_name_str = method_sym.to_s.dup
          if !@set_object.respond_to?(method_sym) && set_name_str.slice!(/\?\z/) == '?'
            @set_object.include?(set_name_str.to_sym, &block)
          else
            @set_object.method(method_sym).call(*args, &block)
          end
        end
      end

    end # class AttrQuery
  end # class AttributeSet
end # module ActiveModel
