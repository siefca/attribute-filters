# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::AttributeSet class
# used to interact with attribute sets.

require 'set'

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  # This class is a data structure used to store
  # sets of attributes.
  class AttributeSet < ::Set
  end
end
