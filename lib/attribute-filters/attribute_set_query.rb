# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeSet::Query class
# used to interact with attribute sets.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  class AttributeSet
    # This class contains proxy methods used to interact with
    # AttributeSet instances. It's responsible for all of the DSL magic
    # that allows sweet constructs like:
    #   some_attribute_set.all.present?
    class Query < BasicObject
      # Creates new query object.
      # 
      # @param set_object [AttributeSet] attribute set for which the query will be made
      # @param am_object [Object] model object which has access to attributes (may be an instance of ActiveRecord or similar)
      def initialize(set_object, am_object)
        @set_object = set_object
        @am_object = am_object
        @next_method = nil
      end

      # This is a proxy method that causes some calls to be
      # queued to for the next call. Is allows to create semi-natural
      # syntax when querying attribute sets.
      # 
      # When +method_sym+ is set to +:all+ or +:any+ then new query is created
      # and the next method given in chain is passed to each element of the set with
      # question mark added to its name.
      # 
      # Example:
      #   some_attribute_set.all.present?
      # is converted to
      #   some_attribute_set.all? { |atr| atr.present? }
      # 
      # When +method_sym+ is set to +list+ or +show+ then new query
      # is constructed and the next method given in chain is passed to
      # any element collected by applying +select+ to set.
      # 
      # Example:
      #   some_attribute_set.list.present?
      # is converted to
      #   some_attribute_set.select { |atr| atr.present? }
      # 
      # @param method_sym [Symbol,String] name of method that will be queued or called on attribute set
      # @param args [Array] optional arguments to be passed to a method call or to a queued method call
      # @yield optional block to be passed to a method call or to a queued method call
      # @return [Object] the returned value is passed back from called method
      def method_missing(method_sym, *args, &block)
        case method_sym.to_sym
        when :are, :is, :be, :should
          return self
        end
        if @next_method.nil?
          case method_sym.to_sym
          when :all, :any, :none, :one
            ::ActiveModel::AttributeSet::Query.new(@set_object, @am_object).   # new obj. == thread-safe
              next_step(method_sym.to_s << "?", args, block)
          when :list, :show
            ::ActiveModel::AttributeSet::Query.new(@set_object, @am_object).
              next_step(:select, args, block)
          else
            r = @set_object.method(method_sym).call(*args, &block)
            return r if r.respond_to?(:__in_as_proxy) || !r.is_a?(::ActiveModel::AttributeSet)
            ::ActiveModel::AttributeSet::Query.new(r, @am_object)
          end
        else
          m, args, block = @next_method
          @next_method = nil
          r = @set_object.method(m).call { |a| @am_object[a].method(method_sym).call(*args, &block) }
          return r if r.respond_to?(:__in_as_proxy) || !r.is_a?(::ActiveModel::AttributeSet)
          ::ActiveModel::AttributeSet::Query.new(r, @am_object)
        end
      end

      # @private 
      def respond_to?(name)
        case name.to_sym
        when :are, :is, :be, :should, :all, :any, :none, :one, :list, :show, :__in_as_proxy
          true
        else
          @set_object.respond_to?(name)
        end
      end

      # @private
      def is_a?(klass)
        super || @set_object.is_a?(klass)
      end
      alias_method :kind_of?, :is_a?

      protected

      # Queues any method of the given name to be called when next
      # query (method call) is made.
      # 
      # @param method_name [Symbol] name of a method to be called on next call to any query method
      # @param args [Array] arguments to be passed to the called method
      # @param block [Proc] code block to be passed to the called method
      # @return [AttributeSet] current query object
      def next_step(method_name, args, block)
        @next_method = [method_name, args, block]
        return self
      end
    end # class Query
  end # class AttributeSet
end # module ActiveModel
