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
      # @overload initialize(am_object)
      #   Creates new query object and uses empty set as an underlying object.
      #   @param am_object [Object] model object which has access to attributes (may be an instance of ActiveRecord or similar)
      #   @return [AttributeSet::Query] query object
      # 
      # @overload initialize(set_object, am_object)
      #   @param set_object [AttributeSet,String,Symbol,Array] attribute set for which the query will be made or
      #    known attribute set name (symbol or string) existing within the given model or an array uset to create a new set
      #   @param am_object [Object] model object which has access to attributes (may be an instance of ActiveRecord or similar)
      #   @return [AttributeSet::Query] query object      
      def initialize(set_object, am_object = nil)
        if am_object.nil?
          am_object = set_object
          unless am_object.included_modules.include?(::ActiveModel::AttributeFilters)
            raise ::ArgumentError, "incompatible object passed to AttributeSet::Query (not a model class?)"
          end
          set_object = ::ActiveModel::AttributeSet.new
        end

        if set_object.is_a?(::Symbol) || set_object.is_a?(::String)   # global set assigned to model class
          set_object = am_object.attribute_set_simple(set_object)     #  - duplicated in class method that gets a set
        elsif !set_object.nil? && !set_object.is_a?(::ActiveModel::AttributeSet) # any other object
          set_object = ::ActiveModel::AttributeSet.new(set_object)    #  - duplicated in AttributeSet initializer
        end

        @set_object = set_object                                      # AttributeSet (assuming it's duplicated if needed)
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
        method_sym = method_sym.to_sym

        # set name as a method name
        if @set_object.nil?
          @set_object = @am_object.class.attribute_set(method_sym)
          return self
        end

        # neutral method
        case method_sym
        when :are, :is, :be, :should
          return self
        end

        # special selectors
        if @next_method.nil?
          case method_sym

          when :all, :any, :none, :one
            ::ActiveModel::AttributeSet::Query.new(@set_object, @am_object).   # new obj. == thread-safe
              next_step(method_sym.to_s << "?", args, block)

          when :list, :show
            ::ActiveModel::AttributeSet::Query.new(@set_object, @am_object).
              next_step(:select, args, block)

          when :valid?, :is_valid?, :are_valid?, :all_valid?, :are_all_valid?
            self.all.valid?

          when :invalid?, :is_not_valid?, :any_invalid?, :are_not_valid?, :not_valid?, :is_any_invalid?
            self.any.invalid?

          when :changed?, :any_changed?, :have_changed?, :have_any_changed?, :is_any_changed?, :has_any_changed?, :has_changed?
            self.any.changed?

          when :unchanged?, :none_changed?, :nothing_changed?, :is_unchanged?, :are_all_unchanged?,
               :all_unchanged?, :havent_changed?, :arent_changed?, :are_not_changed?, :none_changed?, :not_changed?
            self.all.unchanged?

          else
            r = @set_object.public_method(method_sym).call(*args, &block)
            return r if r.respond_to?(:__in_as_proxy) || !r.is_a?(::ActiveModel::AttributeSet)
            ::ActiveModel::AttributeSet::Query.new(r, @am_object)
          end
        else
          n_m, n_args, n_block = @next_method
          @next_method = nil
          # m contains a method that we should call on a set of names (e.g. all? or any?)
          # method_sym contains a method to be called on each attribute from a set (e.g. present?)
          r = case method_sym

          when :valid?
            @am_object.valid?
            method_for_each_attr(n_m, *args) { |atr| not @am_object.errors.include?(atr.to_sym) }

          when :invalid?
            @am_object.valid?
            method_for_each_attr(n_m, *args) { |atr| @am_object.errors.include?(atr.to_sym) }

          when :changed?
            method_for_each_attr(n_m, *args) { |atr| @am_object.changes.key?(atr) }

          when :unchanged?
            method_for_each_attr(n_m, *args) { |atr| not @am_object.changes.key?(atr) }

          else
            @set_object.public_method(n_m).call(*n_args) do |atr|
              @am_object.public_send(atr).public_method(method_sym).call(*args, &block)
            end

          end
          return r if r.respond_to?(:__in_as_proxy) || !r.is_a?(::ActiveModel::AttributeSet)
          ::ActiveModel::AttributeSet::Query.new(r, @am_object)
        end
      end

      # @private 
      def respond_to?(name)
        case name.to_sym
        when :are, :is, :be, :should, :all, :any, :none, :one, :list, :show, :__in_as_proxy
          true
        when :invalid?, :is_not_valid?, :any_invalid?, :are_not_valid?, :not_valid?, :is_any_invalid?
          true
        when :valid?, :is_valid?, :are_valid?, :all_valid?, :are_all_valid?
          true
        when :changed?, :any_changed?, :have_changed?, :have_any_changed?, :is_any_changed?, :has_any_changed?, :has_changed?
          true
        when :unchanged?, :none_changed?, :nothing_changed?, :is_unchanged?, :are_all_unchanged?,
             :all_unchanged?, :havent_changed?, :arent_changed?, :are_not_changed?, :none_changed?, :not_changed?
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

      # @private
      def instance_of?(klass)
        super || @set_object.instance_of?(klass)
      end

      # @private
      def instance_eval(*args, &block)
        @set_object.instance_eval(*args, &block)
      end

      # @private
      def instance_exec(*args, &block)
        @set_object.instance_exec(*args, &block)
      end

      # Gets values of attributes from current set.
      # If an attribute does not exist it puts +nil+ in its place.
      # 
      # @return [Array] attribute values
      def values
        r = []
        @am_object.for_each_attr_from_set(@set_object,  :process_all,
                                                        :process_blank,
                                                        :no_presence_check,
                                                        :include_missing) { |a| r << a }
        r
      end

      # Gets attribute names and their values for attributes from current set.
      # If an attribute does not exist it puts +nil+ as its value.
      # 
      # @return [Hash{String => Object}] attribute names and their values
      def values_hash
        r = {}
        @am_object.for_each_attr_from_set(@set_object,  :process_all,
                                                        :process_blank,
                                                        :no_presence_check,
                                                        :include_missing) { |a, n| r[n] = a }
        r
      end

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

      private

      def method_for_each_attr(m, *args, &block)
        @set_object.public_method(m).call(*args, &block)
      end
    end # class Query
  end # class AttributeSet
end # module ActiveModel
