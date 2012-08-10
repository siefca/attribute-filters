# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
#
# This file contains ActiveModel::AttributeSet annotation methods.
# Annotations are additional values assigned to attribute names in a set.
# They are halpful when there is a need to memorize some additional properties or operations.

module ActiveModel::AttributeSet::Annotations

  # Adds an annotation to the given attribute.
  # @param atr_name [String,Symbol] attribute name
  # @param name [String,Symbol] annotation name
  # @param value [Object] annotation value
  # @return [void]
  def annotate(atr_name, name, value)
    atr_name = atr_name.to_s
    unless include?(atr_name)
      raise ArgumentError, "attribute '#{atr_name}' must exist in order to annotate it"
    end
    @annotations ||= Hash.new
    @annotations[atr_name] ||= Hash.new
    @annotations[atr_name][name.to_sym] = value
  end
  alias_method :add_op,   :annotate
  alias_method :bind_op,  :annotate

  # Tests if a set has annotations.
  # @return [Boolean] +true+ if there are any annotations, +false+ otherwise
  def has_annotations?
    not (annotations.nil? || annotations.empty?)
  end

  # Gets an annotation for the specified attribute.
  # If the second argument is ommited, it returns
  # all annotations for the specified attribute.
  # 
  # @param atr_name [String,Symbol] attribute name
  # @param annotation [String,Symbol] annotation name
  # @return [Object,Hash,nil] annotations, value of a single annotation or +nil+ if not found
  def annotation(atr_name, annotation = nil)
    return nil if @annotation.nil?
    r = @annotations[atr_name]
    return nil if r.nil?
    if annotation.nil?
      r.dup
    else
      r = r[annotation.to_sym]
      r.is_a?(Enumerable) ? r.dup : r
    end
  end
  alias_method :get_annotation, :annotation

  # Deletes annotations or single annotation key for the given attribute.
  # If the +annotation+ argument is not given or is +nil+
  # then all annotation keys for the given attribute name are deleted.
  # 
  # @param atr_name [String,Symbol] attribute name
  # @param annotation [String,Symbol] annotation key
  # @return [Hash,Object,nil] deleted annotations (hash),
  #  deleted annotation value or +nil+ if there wasn't anything to delete
  def delete_annotation(atr_name, annotation = nil)
    return nil if @annotations.nil?
    atr_name = atr_name.to_s
    if annotation.nil?
      @annotations.delete(atr_name)
    elsif @annotations.has_key?(atr_name)
      @annotations[atr_name].delete(annotation.to_sym)
    else
      nil
    end
  end

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
