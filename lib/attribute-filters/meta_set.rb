# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2012 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file contains ActiveModel::MetaSet class
# used to store and compare sets of attribute sets.

# @abstract This namespace is shared with ActveModel.
module ActiveModel
  # This is a kind of AttributeSet class
  # but its purpose it so store other information
  # than attribute names.
  class MetaSet < Hash
    include AttributeFilters::AttributeSetMethods

    private

    # Internal method for merging sets.
    def merge_set(my_v, ov, my_class = self.class)
      if my_v.is_a?(my_class) && ov.is_a?(my_class)
        my_v.deep_merge(ov)
      else
        my_v
      end
    end
  end
end # module ActiveModel
