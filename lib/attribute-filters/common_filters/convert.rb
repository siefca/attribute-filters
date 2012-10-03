# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Convert module
# containing ready-to-use filtering methods for performing the type conversion.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common   

      # This module contains attribute filters responsible for converting the attributes.
      module Convert
        extend CommonFilter

        def attributes_convert(set_name, default_key, &block)
          filter_attrs_from_set(set_name) do |atr_val, atr_name, set_obj|
            AttributeFiltersHelpers.each_element(atr_val) do |v|
              begin
                yield(v, atr_name, set_obj)
              rescue NoMethodError, ArgumentError
                raise unless set_obj.has_annotation?(atr_name, default_key)
                set_obj.annotation(atr_name, default_key)
              end
            end
          end
        end
        private :attributes_convert

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes.
          def attributes_convert(set_name, keys_params, *args)
            args.each do |arg|
              if arg.is_a?(Hash)
                arg.each_pair do |atr_name, v|
                  attributes_that(set_name, atr_name)
                  keys_params.each_pair do |annotation_key, param_names|
                    annotate_attributes_with_params(set_name, atr_name, v, annotation_key, *param_names)
                  end
                end
              else
                attributes_that(set_name, args)
              end
            end
          end
          private :attributes_convert
        end # module ClassMethods

        # Convert attributes to strings.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_strings+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_s
          attributes_convert(:should_be_strings, :to_s_default) do |v, atr_name, set_obj|
            if set_obj.has_annotation?(atr_name, :to_s_base)
              v.to_s(set_obj.annotation(atr_name, :to_s_base) || 10)
            else
              v.to_s
            end
          end
        end
        alias_method :attributes_to_strings, :attributes_to_s

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_s(*args)
            attributes_convert(:should_be_strings,
              {
                :to_s_default => [:default, :on_error, :to_s_default],
                :to_s_base => [:base, :with_base, :to_s_base]
              }, *args)
          end
          alias_method :convert_to_string,      :attributes_to_s
          alias_method :convert_to_strings,     :attributes_to_s
          alias_method :attributes_to_strings,  :attributes_to_s
          alias_method :attribute_to_strings,   :attributes_to_s
          alias_method :attribute_to_s,         :attributes_to_s
        end # module ClassMethods

        # Convert attributes to integers.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_integers+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_i
          attributes_convert(:should_be_integers, :to_i_default) { |v| v.to_i }
        end
        alias_method :attributes_to_integers, :attributes_to_i

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_i(*args)
            attributes_convert(:should_be_integers, {:to_i_default => [:default, :on_error, :to_i_default]}, *args)
          end
          alias_method :convert_to_integer,     :attributes_to_i
          alias_method :convert_to_integers,    :attributes_to_i
          alias_method :attributes_to_integers, :attributes_to_i
          alias_method :attribute_to_integers,  :attributes_to_i
          alias_method :attribute_to_i,         :attributes_to_i
        end # module ClassMethods

        # Convert attributes to floats.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_floats+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_f
          attributes_convert(:should_be_floats, :to_f_default) { |v| v.to_f }
        end
        alias_method :attributes_to_floats,   :attributes_to_f

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_f(*args)
            attributes_convert(:should_be_floats,  :to_f_default, [:default, :on_error, :to_f_default], *args)
          end
          alias_method :convert_to_float,      :attributes_to_f
          alias_method :convert_to_floats,     :attributes_to_f
          alias_method :attributes_to_floats,  :attributes_to_f
          alias_method :attribute_to_floats,   :attributes_to_f
          alias_method :attribute_to_f,        :attributes_to_f
        end # module ClassMethods

        # Convert attributes to numbers.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_numbers+. It works the same as converting
        # to floats but uses different attribute set.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_numbers
          attributes_convert(:should_be_numbers, :to_f_default) { |v| v.to_f }
        end
        alias_method :attribute_to_numbers, :attributes_to_numbers

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_numbers(*args)
            attributes_convert(:should_be_numbers,  :to_f_default, [:default, :on_error, :to_number_default,
                                                                   :to_num_default], *args)
          end
          alias_method :convert_to_number,     :attributes_to_numbers
          alias_method :convert_to_numbers,    :attributes_to_numbers
          alias_method :attribute_to_numbers,  :attributes_to_numbers
        end # module ClassMethods

        # Convert attributes to rationals.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_rationals+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_r
          attributes_convert(:should_be_rationals, :to_r_default) { |v| v.to_r }
        end
        alias_method :attributes_to_rationals,  :attributes_to_r
        alias_method :attributes_to_fractions,  :attributes_to_r

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_r(*args)
            attributes_convert(:should_be_rationals, {:to_r_default => [:default, :on_error, :to_r_default]}, *args)
          end
          alias_method :convert_to_rational,      :attributes_to_r
          alias_method :convert_to_rationals,     :attributes_to_r
          alias_method :convert_to_fraction,      :attributes_to_r
          alias_method :convert_to_fractions,     :attributes_to_r
          alias_method :attributes_to_rationals,  :attributes_to_r
          alias_method :attribute_to_rationals,   :attributes_to_r
          alias_method :attribute_to_fraction,    :attributes_to_r
        end # module ClassMethods

        # Generic method for calling all the conversion methods.
        # @return [void]
        def convert_attributes
          attributes_to_r
          attributes_to_f
          attributes_to_numbers
          attributes_to_i
          attributes_to_s
        end

      end # module Convert

      include Convert

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
