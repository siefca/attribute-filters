# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains some helper methods for Attribute Filters.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters

    # This module contains internal helpers
    # used to process filters and sets.
    module AttributeFiltersHelpers

      # @private
      def process_flags(args)
        flags = ActiveModel::AttributeFilters::PROCESSING_FLAGS.dup
        while flags.key?(a=args[0]) do
          flags[a] = !!args.shift
        end
        flags
      end
      module_function :process_flags

    end # module AttributeFiltersHelpers
  end # module AttributeFilters
end # module ActiveModel
