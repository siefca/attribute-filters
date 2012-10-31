# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeFilters::Common::Bare module.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  module AttributeFilters
    # This module contains common, ready-to-use filtering methods.
    module Common   

      # This module contains bare attribute filters.
      module Bare
        extend CommonFilter

        # This submodule contains class methods used to easily define filter.
        module ClassMethods
        end # module ClassMethods

      end # module Bare

      include Bare

    end # module Common
  end # module AttributeFilters
end # module ActiveModel
