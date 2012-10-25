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

        # Helper that is used by all converting filters.
        def attributes_convert(set_name, default_key, *params, &block)
          filter_attrs_from_set(set_name, *params) do |atr_val, atr_name, set_obj|
            AFHelpers.each_element(atr_val) do |v|
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
              v = 0 if v.nil?
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
            setup_attributes_that :should_be_strings, args,
              {
                :to_s_default => [:default, :on_error, :to_s_default],
                :to_s_base => [:base, :with_base, :to_s_base]
              }, :to_s_base
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
          attributes_convert(:should_be_integers, :to_i_default) do |v, atr_name, set_obj|
            if set_obj.has_annotation?(atr_name, :to_i_base)
              v.to_i(set_obj.annotation(atr_name, :to_i_base) || 10)
            else
              v.to_i
            end
          end
        end
        alias_method :attributes_to_integers, :attributes_to_i

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_i(*args)
            setup_attributes_that :should_be_integers, args,
              {
                :to_i_default => [:default, :on_error, :to_i_default],
                :to_i_base => [:base, :with_base, :to_i_base]
              }, :to_i_base
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
            setup_attributes_that :should_be_floats, args,
              { :to_f_default => [:default, :on_error, :to_f_default] },
              :to_f_default
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
            setup_attributes_that :should_be_numbers, args,
              { :to_num_default => [:default, :on_error, :to_number_default, :to_num_default] },
              :to_num_default
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
            setup_attributes_that :should_be_rationals, args,
              { :to_r_default => [:default, :on_error, :to_r_default] },
              :to_r_default
          end
          alias_method :convert_to_rational,      :attributes_to_r
          alias_method :convert_to_rationals,     :attributes_to_r
          alias_method :convert_to_fraction,      :attributes_to_r
          alias_method :convert_to_fractions,     :attributes_to_r
          alias_method :attributes_to_rationals,  :attributes_to_r
          alias_method :attribute_to_rationals,   :attributes_to_r
          alias_method :attribute_to_fraction,    :attributes_to_r
        end # module ClassMethods

        # Convert attributes to boolean values.
        # 
        # The attrubutes are taken from the attribute set
        # called +should_be_boolean+.
        # 
        # @note If a value of currently processed attribute is an array
        #  then each element of the array is changed.
        # 
        # @return [void]
        def attributes_to_b
          attributes_convert(:should_be_boolean, :to_b_default, :process_blank) { |v| !!v }
        end
        alias_method :attributes_to_boolean, :attributes_to_b

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
          # Registers attributes that should be converted.
          def attributes_to_b(*args)
            setup_attributes_that :should_be_boolean, args,
              { :to_b_default => [:default, :on_error, :to_b_default] },
              :to_b_default
          end
          alias_method :convert_to_boolean,      :attributes_to_b
          alias_method :convert_to_booleans,     :attributes_to_b
          alias_method :attributes_to_booleans,  :attributes_to_b
          alias_method :attribute_to_booleans,   :attributes_to_b
        end # module ClassMethods

        # Generic method for calling all the conversion methods.
        # @return [void]
        def convert_attributes
          attributes_to_r
          attributes_to_f
          attributes_to_numbers
          attributes_to_i
          attributes_to_s
          attributes_to_b
        end

      end # module Convert

      include Convert

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
