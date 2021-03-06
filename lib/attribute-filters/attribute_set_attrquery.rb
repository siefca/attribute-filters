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
      # Creates new query object.
      # 
      # @param set_object [AttributeSet] attribute set containing set names for which the query will be made
      # @param am_object [Object] model object which has access to attributes (may be an instance of ActiveRecord or similar)
      # @param attribute_name [Sting,Symbol] name of attribute the query is made for
      def initialize(attribute_name = nil, am_object = nil)
        if am_object.nil?
          am_object = attribute_name
          attribute_name = nil
          unless am_object.included_modules.include?(::ActiveModel::AttributeFilters)
            raise ::ArgumentError, "incompatible object passed to AttributeSet::AttrQuery (not a model class?)"
          end
        end
        @am_object = am_object
        @next_method = nil
        unless attribute_name.nil?
          @set_object = @am_object.class.filter_attribute(attribute_name)
          @attribute_name = attribute_name.to_s
        end
      end

      # This is a proxy method that causes some calls to be
      # intercepted. Is allows to create semi-natural
      # syntax when querying attribute sets containing set names.
      # 
      # When the called method name ends with question mark then
      # its name is considered to be an attribute set name that
      # should be tested for presence of the attribute. To use
      # that syntax you have to be sure that there is no already
      # defined method for AttributeSet object which name ends
      # with question mark. Otherwise you may get false positives
      # or a strange errors when trying to test if attribute belongs
      # to a set. The real method call will override your check.
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
        method_sym = method_sym.to_sym

        if @attribute_name.nil?
          @attribute_name = method_sym.to_s
          @set_object = @am_object.class.filter_attribute(@attribute_name)
          return self
        end

        case method_sym
        when :are, :is, :one, :is_one, :in, :list, :be, :should,
             :the, :a, :sets, :in_sets, :set, :in_a_set, :in_set, :belongs_to
          self

        when :belongs_to?, :in?, :in_set?, :in_a_set?, :in_the_set?,
             :the_set?, :set?, :is_one_that?, :one_that?, :that?
          if args.present? && args.is_a?(::Array)
            args = args.map{ |a| a.to_sym if a.respond_to?(:to_sym) }
          end
          @set_object.include?(*args, &block)

        when :accessible?, :is_accessible?
          @am_object.class.accessible_attributes.include?(@attribute_name)

        when :inaccessible?, :is_inaccessible?
          @am_object.all_inaccessible_attributes.include?(@attribute_name)

        when :protected?, :is_protected?
          @am_object.class.protected_attributes.include?(@attribute_name)

        when :virtual?, :is_virtual?
          @am_object.class.attribute_filters_virtual.include?(@attribute_name)

        when :semi_real?, :is_semi_real?
          @am_object.class.treat_as_real.include?(@attribute_name)

        when :valid?, :is_valid?
          return false unless @am_object.send(:__all_attributes).include?(@attribute_name)
          return true if @am_object.valid?
          not @am_object.errors.has_key?(@attribute_name.to_sym)

        when :invalid?, :is_invalid?
          return true unless @am_object.send(:__all_attributes).include?(@attribute_name)
          return false if @am_object.valid?
          @am_object.errors.has_key?(@attribute_name.to_sym)

        when :changed?, :is_changed?, :has_changed?
          return false unless @am_object.changed? && @am_object.send(:__all_attributes).include?(@attribute_name)
          @am_object.changes.key?(@attribute_name)

        when :unchanged?, :is_unchanged?, :hasnt_changed?, :not_changed?
          return true unless @am_object.changed?
          @am_object.changes.key?(@attribute_name)

        else
          set_name_str = method_sym.to_s
          if !@set_object.respond_to?(method_sym) && set_name_str.slice!(/\?\z/) == '?'
            @set_object.include?(set_name_str.to_sym, &block)
          else
            @set_object.public_method(method_sym).call(*args, &block)
          end
        end
      end

      # Gets value of current attribute.
      # If the attribute does not exist it returns +nil+.
      # 
      # @return [Object] the value of an attribute
      def value
        @am_object.respond_to?(@attribute_name) ? @am_object.public_send(@attribute_name) : nil
      end

      # @private
      def respond_to?(name)
        case name.to_sym
        when :are, :is, :one, :is_one, :in, :list, :be, :should, :the, :a, :sets, :in_sets,
             :set, :in_a_set, :in_set, :in?, :in_set?, :in_a_set?, :in_the_set?, :the_set?, :set?,
             :is_one_that?, :one_that?, :that?, :belongs_to?, :belongs_to,
             :protected?, :is_protected?, :inaccessible?, :is_inaccessible?,
             :accessible?, :is_accessible?, :valid?, :is_valid?, :invalid?, :is_invalid?,
             :virtual?, :is_virtual?, :semi_real?, :is_semi_real?,
             :changed?, :has_changed?, :is_changed?, :unchanged?, :hasnt_changed?, :is_unchanged?, :not_changed?
          true
        else
          @set_object.respond_to?(name) || name.to_s.slice(-1,1) == '?'
        end
      end
    end # class AttrQuery
  end # class AttributeSet
end # module ActiveModel
