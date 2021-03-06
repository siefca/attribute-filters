# encoding: utf-8

require 'attribute-filters'
require 'attribute-filters/version'
require 'attribute-filters/backports'
require 'attribute-filters/helpers'

require 'attribute-filters/attribute_set_enum'
require 'attribute-filters/attribute_set'
require 'attribute-filters/meta_set'
require 'attribute-filters/attribute_set_annotations'
require 'attribute-filters/attribute_set_query'
require 'attribute-filters/attribute_set_attrquery'

require 'attribute-filters/dsl_sets'
require 'attribute-filters/dsl_filters'
require 'attribute-filters/dsl_attr_virtual'
require 'attribute-filters/common_filters'

if defined? ::Rails
  require 'attribute-filters/railtie'
else
  require 'attribute-filters/active_model_insert'
end

