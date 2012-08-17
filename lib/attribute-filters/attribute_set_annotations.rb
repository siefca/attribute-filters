# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
#
# This file contains ActiveModel::AttributeSet annotation methods.
# Annotations are additional values assigned to attribute names in a set.
# They are halpful when there is a need to memorize some additional properties or operations.

# This module contains annotations support for AttributeSet.
# It is included in AttirbuteSet class automatically
# and allows adding, deleting and removing annotations
# to certain elements of attribute sets. One element (attribute name)
# 
module ActiveModel::AttributeSet::Annotations

  # Adds an annotation to the given attribute.
  # 
  # @param atr_name [String,Symbol] attribute name
  # @param name [String,Symbol] annotation key
  # @param value [Object] annotation value
  # @raise [ArgumentError] when the given attribute name does not exist in a set
  # @return [void]
  def annotate(atr_name, name, value)
    atr_name = atr_name.to_s unless atr_name.blank?
    unless include?(atr_name)
      raise ArgumentError, "attribute '#{atr_name}' must exist in order to annotate it"
    end
    @annotations ||= Hash.new
    @annotations[atr_name] ||= Hash.new
    @annotations[atr_name][name.to_sym] = value
  end
  alias_method :add_op,   :annotate
  alias_method :bind_op,  :annotate

  # Tests if an annotation of the given name exists in a set or if set has annotations.
  # 
  # @overload has_annotation?
  #   Tests if set has any annotations.
  #   @return [Boolean] +true+ if the current set has any annotations, +false+ otherwise
  # 
  # @overload has_annotation?(attribute_name)
  #   Tests if any annotation key for the attribute of the given name exists in a set.
  #   @param attribute_name [Symbol,String] name of an attribute
  #   @return [Boolean] +true+ if the current set has any annotations for +attribute_name+, +false+ otherwise
  # 
  # @overload has_annotation?(attribute_name, *annotation_keys)
  #   Tests if any of the annotation keys for the attribute of the given name exists in a set.
  #   @param attribute_name [Symbol,String] name of an attribute
  #   @param annotation_keys [Array<String,Symbol>] annotation key names to check
  #   @return [Boolean] +true+ if the current set has at least one of the given +annotation_keys+ for +attribute_name+,
  #    +false+ otherwise
  def has_annotation?(*args)
    return false if annotations.nil? || annotations.empty?
    return true if args.size == 0
    atr_name = args.shift.to_s
    a_group = annotations[atr_name]
    a_group.blank? and return false
    args.empty? and return true
    args.any? { |a_name| a_group.key?(a_name.to_sym) }
  end
  alias_method :has_annotations?, :has_annotation?

  # Gets an annotation for the specified attribute.
  # If the second argument is ommited, it returns
  # all annotations for the specified attribute.
  # 
  # @param atr_name [String,Symbol] attribute name
  # @param annotation_names [Array<String,Symbol>] optional annotation key(s)
  # @return [Object,Hash,nil] duplicate of annotations hash, value of a single annotation or +nil+ if not found,
  #  or array of values (filled with +nil+ objects if not found)
  def annotation(atr_name, *annotation_names)
    atr_name.present? or return nil
    has_annotations? or return nil
    an_group = annotations[atr_name.to_s]
    return nil if an_group.nil?
    case annotation_names.size
    when 0
      an_group.dup
    when 1
      r = an_group[annotation_names.first.to_sym]
      r.is_a?(Enumerable) ? r.dup : r
    else
      annotation_names.map do |a|
        r = an_group[a.to_sym]
        r.is_a?(Enumerable) ? r.dup : r
      end
    end
  end
  alias_method :get_annotation,   :annotation
  alias_method :get_annotations,  :annotation

  # Deletes annotations or single annotation key for the given attribute.
  # If the +annotation+ argument is not given or is +nil+
  # then all annotation keys for the given attribute name are deleted.
  # 
  # @param atr_name [String,Symbol] attribute name
  # @param annotation [String,Symbol] annotation key
  # @return [Hash,Object,nil] deleted annotations (hash),
  #  deleted annotation value or +nil+ if there wasn't anything to delete
  def delete_annotation(atr_name, annotation = nil)
    return nil if @annotations.nil? || atr_name.blank?
    atr_name = atr_name.to_s
    if annotation.nil?
      @annotations.delete(atr_name)
    elsif @annotations.has_key?(atr_name)
      @annotations[atr_name].delete(annotation.to_sym)
    else
      nil
    end
  end
  alias_method :delete_annotations, :delete_annotation

  # Removes all annotations.
  # @return [void]
  def remove_annotations
    @annotations = nil
  end

  private

  def annotations
    @annotations
  end

  def copy_annotations(o)
    @annotations ||= Hash.new
    o.each_pair do |atr, annotations_group|
      if include?(atr)
        current_group = (@annotations[atr] ||= Hash.new)
        annotations_group.each_pair do |annotation_name, v|
          current_group[annotation_name] ||= (v.is_a?(Enumerable) ? v.dup : v)
        end
      end
    end
  end

  def copy_annotations(o)
    return unless o.is_a?(self.class) && o.has_annotations?
    @annotations ||= Hash.new
    o.send(:annotations).each_pair do |atr, annotations_group|
      if include?(atr)
        current_group = (@annotations[atr] ||= Hash.new)
        annotations_group.each_pair do |annotation_name, v|
          current_group[annotation_name] ||= (v.is_a?(Enumerable) ? v.dup : v)
        end
      end
    end
  end

  def copy_missing_annotations(from, other)
    @annotations ||= Hash.new
    from.each_pair do |atr, annotations_group|
      if include?(atr) && (other.nil? || !other.has_key?(atr))
        current_group = (@annotations[atr] ||= Hash.new)
        annotations_group.each_pair do |annotation_name, v|
          current_group[annotation_name] ||= (v.is_a?(Enumerable) ? v.dup : v)
        end
      end
    end
  end

  def remove_different_annotations(other)
    return unless other.is_a?(self.class) && other.has_annotations?
    @annotations ||= Hash.new
    other.send(:annotations).each_pair do |atr, annotations_group|
      include?(atr) and delete_annotation(atr)
    end
  end

end