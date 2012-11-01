Common filters
--------------

## List of filters ##

See the
[`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
for descriptions of common filtering modules.

Terms used when describing filters:

> Callback method – a method that does the filtering, may be called manually, registered as a callback (e.g. with `after_` or `before_` methods from Active Record) or called automatically when `filter_attributes` is called.

> Class-level helper – a DSL method that may be used in a model class to setup a filter.

> Class-level helper aliases – aliases of class-level DSL methods used to setup a filter.

> Uses set – a global attribute set (assigned to model) that is used to store information on attributes that should be filtered and optional parameters (stored as annotations) that are sometimes used by filtering method.

> Operates on – data types that the filtering method operates on.

> Uses annotations – a statement concerning the use of annotations (as parameters) by the filtering method and a list of annotations and their meanings.

> Parameters' aliases – aliases of parameters that can be used when utilizing class-level helper to setup the given filter.

> Default annotation – a parameter which value is taken from a value assigned to the whole attribute when setting up a filter.

### Case ###

* Submodule: [`Case`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Case.html)

#### `capitalize_attributes` ####

Capitalizes attributes.

* Callback method: `capitalize_attributes`
* Class-level helper: `capitalize_attributes(*attribute_names)`
* Class-level helper aliases: `capitalize_attribute`, `capitalizes_attribute`, `capitalizes_attributes`
* Uses set: `:should_be_capitalized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  capitalizes_attribute :name
  before_validation     :capitalize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  has_attributes_that :should_be_capitalized => [ :name ]
  before_validation   :capitalize_attributes
end
```

Then:

> `"some name"`

will become:

> `"Some name"`

#### `fully_capitalize_attributes` ####

Capitalizes attributes and squeezes spaces that separate strings.

* Callback method: `fully_capitalize_attributes`
* Class-level helper: `fully_capitalize_attributes(*attribute_names)`
* Class-level helper aliases: `fully_capitalize_attribute`, `fully_capitalizes_attribute`, `fully_capitalizes_attributes`
* Uses set: `:should_be_fully_capitalized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  fully_capitalizes_attribute :name
  before_validation :fully_capitalize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  has_attributes_that :should_be_fully_capitalized => [ :name ]
  before_validation   :fully_capitalize_attributes
end
```

Then:

> `"some      name"`

will become:

> `"Some Name"`

#### `titleize_attributes` ####

Titleizes attributes.

* Callback method: `titleize_attributes`
* Class-level helper: `titleize_attributes(*attribute_names)`
* Class-level helper aliases: `titleize_attribute`, `titleizes_attribute`, `titleizes_attributes`
* Uses set: `:should_be_titleized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  titleizes_attribute :name
  before_validation   :titleize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  has_attributes_that :should_be_titleized => [ :name ]
  before_validation   :titleize_attributes
end
```

Then:

> `"some name"`

will become:

> `"Some Name"`

#### `upcase_attributes` ####

Upcases attributes.

* Callback method: `upcase_attributes`
* Class-level helper: `upcase_attributes(*attribute_names)`
* Class-level helper aliases: `upcase_attribute`, `upcases_attribute`, `upcases_attributes`
* Uses set: `:should_be_upcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  upcases_attribute :name
  before_validation  :upcase_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  has_attributes_that :should_be_upcased => [ :name ]
  before_validation   :upcase_attributes
end
```

Then:

> `"some name"`

will become:

> `"SOME NAME"`

#### `downcase_attributes` ####

Downcases attributes.

* Callback method: `downcase_attributes`
* Class-level helper: `downcase_attributes(*attribute_names)`
* Class-level helper aliases: `downcase_attribute`, `downcases_attribute`, `downcases_attributes`
* Uses set: `:should_be_downcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  downcases_attribute :name
  before_validation   :downcase_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  has_attributes_that :should_be_downcased => [ :name ]
  before_validation   :downcase_attributes
end
```

Then:

> `"SOME NAME"`

will become:

> `"some name"`

### Convert ###

* Submodule: [`Convert`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Convert.html)

#### `attributes_to_s` ####

Converts attributes to strings.

* Callback method: `attributes_to_s`
* Class-level helper: `attributes_to_s(*attribute_names)`
* Class-level helper aliases: `convert_to_strings`, `convert_to_string`, `converts_to_strings`, `converts_to_string`
* Uses set: `:should_be_strings`
* Operates on: numbers, arrays of numbers, hashes of numbers (as values), other convertable types
* Uses annotations: yes
 * `:to_s_default` – a value used in case of a conversion error
 * `:to_s_base` – a base used when converting numbers (2 for binary, 10 for decimal and so on) (default parameter)
* Parameters' aliases:
 * `:to_s_default` – `:default`, `:on_error`
 * `:to_s_base` – `:base`, `:with_base`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_string  :name
  before_validation   :attributes_to_strings
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that :should_be_strings => [ :name ]
  before_validation   :attributes_to_strings
end
```

#### `attributes_to_i` ####

Converts attributes to integers.

* Callback method: `attributes_to_i`
* Class-level helper: `attributes_to_i(*attribute_names)`
* Class-level helper aliases: `convert_to_integers`, `convert_to_integer`, `converts_to_integers`, `converts_to_integer`
* Uses set: `:should_be_integers`
* Operates on: strings, arrays of strings, hashes of strings (as values), other convertable types
* Uses annotations: yes
 * `:to_i_default` – a value used in case of a conversion error
 * `:to_i_base` – a base used when converting numbers (2 for binary, 10 for decimal and so on) (default parameter)
* Parameters' aliases:
 * `:to_i_default` – `:default`, `:on_error`
 * `:to_i_base` – `:base`, `:with_base`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_integer :number
  before_validation   :attributes_to_integers
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that :should_be_integers => [ :number ]
  before_validation   :attributes_to_integers
end
```

#### `attributes_to_f` ####

Converts attributes to floats.

* Callback method: `attributes_to_f`
* Class-level helper: `attributes_to_f(*attribute_names)`
* Class-level helper aliases: `convert_to_floats`, `convert_to_float`, `converts_to_floats`, `converts_to_float`
* Uses set: `:should_be_floats`
* Operates on: strings, arrays of strings, hashes of strings (as values), other convertable types
* Uses annotations: yes
 * `:to_f_default` – a value used in case of a conversion error (default parameter)
* Parameters' aliases:
 * `:to_f_default` – `:default`, `:on_error`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_float :number
  before_validation :attributes_to_floats
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that  :should_be_floats => [ :number ]
  before_validation    :attributes_to_floats
end
```

#### `attributes_to_numbers` ####

Converts attributes to numbers.

Works the same way as `attributes_to_f` but uses different attribute set.

* Callback method: `attributes_to_numbers`
* Class-level helper: `attributes_to_numbers(*attribute_names)`
* Class-level helper aliases: `convert_to_numbers`, `convert_to_number`, `converts_to_numbers`, `converts_to_number`
* Uses set: `:should_be_numbers`
* Operates on: strings, arrays of strings, hashes of strings (as values), other convertable types
* Uses annotations: yes
 * `:to_num_default` – a value used in case of a conversion error (default parameter)
* Parameters' aliases:
 * `:to_num_default` – `:default`, `:on_error`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_number  :number
  before_validation   :attributes_to_numbers
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that :should_be_numbers => [ :number ]
  before_validation   :attributes_to_numbers
end
```

#### `attributes_to_r` ####

Converts attributes to rationals.

* Callback method: `attributes_to_r`
* Class-level helper: `attributes_to_r(*attribute_names)`
* Class-level helper aliases: `convert_to_rationals`, `convert_to_rational`, `converts_to_rationals`, `converts_to_rational`, `convert_to_fractions`, `convert_to_fraction`, `converts_to_fractions`, `converts_to_fraction`
* Uses set: `:should_be_rationals`
* Operates on: strings, arrays of strings, hashes of strings (as values), other convertable types
* Uses annotations: yes
 * `:to_r_default` – a value used in case of a conversion error (default parameter)
* Parameters' aliases:
 * `:to_r_default` – `:default`, `:on_error`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_rational  :number
  before_validation     :attributes_to_rationals
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that :should_be_rationals => [ :number ]
  before_validation   :attributes_to_rationals
end
```

#### `attributes_to_b` ####

Converts attributes to boolean.

* Callback method: `attributes_to_b`
* Class-level helper: `attributes_to_b(*attribute_names)`
* Class-level helper aliases: `convert_to_booleans`, `convert_to_boolean`, `converts_to_booleans`, `converts_to_boolean`
* Uses set: `:should_be_boolean`
* Operates on: objects, arrays of objects, hashes of objects (as values)
* Uses annotations: yes
 * `:to_b_default` – a value used in case of a conversion error (default parameter)
* Parameters' aliases:
 * `:to_b_default` – `:default`, `:on_error`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  converts_to_boolean :number
  before_validation   :attributes_to_boolean
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Convert

  has_attributes_that :should_be_boolean => [ :number ]
  before_validation   :attributes_to_boolean
end
```

### Order ###

* Submodule: [`Order`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Order.html)

#### `reverse_attributes` ####

Reverses order of attribute values.

* Callback method: `reverse_attributes`
* Class-level helper: `reverse_attributes(*attribute_names)`
* Class-level helper aliases: `reverse_attribute`, `reverses_attribute`, `reverses_attributes`
* Uses set: `:should_be_reversed`
* Operates on: strings, arrays of strings, hashes of strings (as values), other enumerable types
* Uses annotations: yes
 * `:reverse_enumerable` – disables recursive traversing of arrays and hashes to filter each element
* Parameters' aliases:
 * `:reverse_enumerable` – `:enum`, `:enums`, `:whole_enums`, `:reverse_enums`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  reverses_attribute :name
  before_validation  :reverse_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  has_attributes_that :should_be_reversed => [ :name ]
  before_validation   :reverse_attributes
end
```

#### `shuffle_attributes` ####

Shuffles order of attribute values.

* Callback method: `shuffle_attributes`
* Class-level helper: `shuffle_attributes(*attribute_names)`
* Class-level helper aliases: `shuffle_attribute`, `shuffles_attribute`, `shuffles_attributes`
* Uses set: `:should_be_shuffled`
* Operates on: strings, arrays of strings, hashes of strings (as values), other enumerable types
* Uses annotations: yes
 * `:shuffle_enumerable` – disables recursive traversing of arrays and hashes to filter each element
 * `:shuffle_generator` – random number generation source passed to the `shuffle` method
* Parameters' aliases:
 * `:shuffle_enumerable` – `:enum`, `:enums`, `:whole_enums`, `:shuffle_enums`
 * `:shuffle_generator` – `:random_generator`, `:generator`, `:rnd`, `:rng`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  shuffles_attribute :name
  before_validation  :shuffle_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  has_attributes_that :should_be_shuffled => [ :name ]
  before_validation   :shuffle_attributes
end
```

### Pick ###

* Submodule: [`Pick`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Pick.html)

#### `pick_attributes` ####

Picks attributes from leading and trailing spaces or other surrounding characters.

* Callback method: `pick_attributes`
* Class-level helper: `pick_attributes(*attribute_names)`
* Class-level helper aliases: `pick_attribute`, `picks_attribute`, `picks_attributes`
* Uses set: `:should_be_picked`
* Operates on: strings, arrays of strings, hashes of string (as values), other enumerable types
* Uses annotations: yes
 * `:pick_enumerable` – disables recursive traversing of arrays and hashes to filter each element
 * `:pick_step` – step of picking the elements (defaults to 1)
 * `:pick_from` – beginning of picked range (defaults to 0)
 * `:pick_to` – end of picked range (defaults to elements count - 1)
 * `:pick_range` – replaces `:pick_from` and `:pick_to`
 * `:pick_separator` – if a value is a string it splits it into elements using the given character(s) or regexp (defaults to "") (default parameter)
 * `:pick_join` – if a value is a string it joins the results using the given character(s) (defaults to the value of `:pick_separator` or `nil` in case of regexp)
* Parameters' aliases:
 * `:pick_enumerable` – `:enum`, `:enums`, `:whole_enums`, `:pick_enums`
 * `:pick_step` – `:step`, `:with_step`, `:each`
 * `:pick_from` – `:from`, `:head`, `:take`, `:first`, `:pick_first`, `:pick_head`
 * `:pick_to` – `:to`, `:tail`, `:last`, `:pick_last`, `:pick_tail`
 * `:pick_range` – `:range`
 * `:pick_separator` – `:separator`, `:regex`, `:split_with`, `:split_separator`
 * `:pick_join` – `:joiner`, `:join`, `:join_with`
                      
Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Pick

  picks_attribute   :name
  before_validation :pick_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  has_attributes_that :should_be_picked => [ :name ]
  before_validation   :pick_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Pick

  picks_attribute   :name, :range => 1..-1, :step => 2
  before_validation :pick_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Pick

  picks_attribute   :name => " "      # default parameter sets separator
  before_validation :pick_attributes
end
```

### Presence ###

* Submodule: [`Presence`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Presence.html)

#### `fill_attributes` ####

Fills blank attributes with the given values.

* Callback method: `fill_attributes`
* Class-level helper: `fill_attributes(*attribute_names)`
* Class-level helper aliases: `fill_attribute`, `fills_attribute`, `fills_attributes`
* Uses set: `:should_be_filled`
* Operates on: objects, arrays of objects, hashes of objects (as values)
* Uses annotations: yes
 * `:fill_enumerable` – disables recursive traversing of arrays and hashes to filter each element
 * `:fill_value` – replacemant value (default parameter)
 * `:fill_any` – flag that causes to fill any attribute value, not just blank ones
* Parameters' aliases:
 * `:fill_enumerable` – `:enums`, `:replace_enumerable`, `:replace_enums`, `:whole_enums`, `:fill_enums`
 * `:fill_value` – `:with`, `:fill_with`, `:fill`, `:value`, `:content`, `:default`, `:fill_value`
 * `:fill_any` – `:all`, `:any`, `:fill_always`, `:always_fill`, `:always`, `:fill_present`, `:fill_all`
                      
Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Presence

  fills_attribute   :name, :with => "none" 
  before_validation :fill_attributes
end
```

or


```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Order

  has_attributes_that :should_be_filled => [ :name => { :fill_value => "not given" } ]
  before_validation   :fill_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Presence

  fills_attribute   :name => "not given"
  before_validation :fill_attributes
end
```


### Strip ###

* Submodule: [`Strip`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Strip.html)

#### `strip_attributes` ####

Strips attributes of leading and trailing spaces.

* Callback method: `strip_attributes`
* Class-level helper: `strip_attributes(*attribute_names)`
* Class-level helper aliases: `strip_attribute`, `strips_attribute`, `strips_attributes`
* Uses set: `:should_be_stripped`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Strip

  strips_attribute  :name
  before_validation :strip_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Strip

  has_attributes_that :should_be_stripped => [ :name ]
  before_validation   :strip_attributes
end
```

Then:

> `"    Some Name    "`

will become:

> `"Some Name"`

### Squeeze ###

* Submodule: [`Squeeze`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Squeeze.html)

#### `squeeze_attributes` ####

Squeezes attributes (squeezes repeating spaces into one).

* Callback method: `squeeze_attributes`
* Class-level helper: `squeeze_attributes(*attribute_names)`
* Class-level helper aliases: `squeeze_attribute`, `squeezes_attribute`, `squeezes_attributes`
* Uses set: `:should_be_squeezed`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: yes
 * `:squeeze_other_str` – argument used when calling [`String#squeeze`](http://www.ruby-doc.org/core/String.html#method-i-squeeze) (optional)
* Parameters' aliases (used with class-level helper):
 * `:squeeze_other_str` – `:other_str`, `:string`, `:with_string`, `:with_characters`, `:with_character`, `:characters`

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  squeezes_attribute :name
  before_validation  :squeeze_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  has_attributes_that :should_be_squeezed => [ :name ]
  before_validation   :squeeze_attributes
end
```

Then:

> `"Some    Name"`

will become:

> `"Some Name"`

#### `squish_attributes` ####

Squishes attributes (removes all whitespace characters on both ends of the string, and then changes remaining consecutive whitespace groups into one space each).

* Callback method: `squish_attributes`
* Class-level helper: `squish_attributes(*attribute_names)`
* Class-level helper aliases: `squish_attribute`, `squishes_attribute`, `squishes_attributes`
* Uses set: `:should_be_squished`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  squishes_attribute :name
  before_validation  :squish_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  has_attributes_that :should_be_squished => [ :name ]
  before_validation   :squish_attributes
end
```

Then:

> `"    Some    Name"`

will become:

> `"Some Name"`

### Split ###

* Submodule: [`Split`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Split.html)

#### `split_attributes` ####

Splits attributes into arrays and puts the results into other attributes or into the same attributes.

* Callback methods: `split_attributes`
* Class-level helpers:
 * `split_attributes(attribute_name, parameters_hash)`
 * `split_attributes(attribute_name)`
* Class-level helper aliases: `split_attribute`, `splits_attribute`, `splits_attributes`
* Uses set: `:should_be_splitted`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: yes
 * `split_pattern` – a pattern passed to [`split`](http://www.ruby-doc.org/core/String.html#method-i-split) method (optional)
 * `split_limit` – a limit passed to `split` method (optional)
 * `split_into` – attribute names used as destinations for parts (default parameter)
 * `split_flatten` – flag that causes resulting array to be flattened
* Parameters' aliases (used with class-level helpers):
 * `split_pattern` – `:with`, `:pattern`
 * `split_limit` – `:limit`
 * `split_into` – `:into`, `:to`, `:destination`
 * `split_flatten` – `:flatten`

If a source attribute is an array or a hash then the filter will recursively traverse it and
operate on each element. The filter works the same way as the `split` method from the `String` class
of Ruby standard library. If the filter encounters an object which is not a string nor an array or a hash,
it simply leaves the value as is.

You can set `:pattern` (`:split_pattern`) and `:limit` (`:split_limit`) arguments passed to
`split` method but note that **a limit is applied to each processed string separately**,
not to the resulting array **(if the processed attribute is an array)**.

For instance, if there is a string containing 3 words:

> `'A B C'`

and the limit is set to 2 then the last two words will be left intact
and placed in a second element of the resulting array:

> `['A', 'B C']`

If the source is an array:

> `['A', 'B B B B', 'C']`

then the result of this operation will be the array of arrays:

> `[ ['A'], ['B B'], ['C'] ]`

As you can see the limit will be applied to its second element.

If there are no destination attributes defined (`:into` or `:split_into` option)
then the resulting array will be written to the currently processed attribute.

If there are destination attributes given then then the resulting array
will be written into them (each subsequent element into each next attribute).
The elements that don't fit in the resulting collection of attributes
are simply ignored **unless the limit is given and it's the same as their count**
(in such case the rest is, as said before, written into the last element).

There is also `flatten` (or `:split_flatten`) parameter that causes the resulting array to be
flattened. Note that it doesn't change how the limits work; they still will be applied but to a single
split results, not to the whole resulting array (in case of array of arrays).

Examples:

(We're using `attr_virtual` here, but in some real-life the source may also be
a real attribute that is written into the database.)

```ruby
class User < ActiveRecord::Base
  # Including common filter for splitting
  include ActiveModel::AttributeFilters::Common::Split

  # Registering virtual attribute
  attr_virtual      :real_name

  # Adding attribute name to :should_be_splitted set
  splits_attribute  :real_name

  # Registering callback method
  before_validation :split_attributes
end
```

or without a `split_attributes` helper:

```ruby
class User < ActiveRecord::Base
  # Including common filter for splitting
  include ActiveModel::AttributeFilters::Common::Split

  # Registering virtual attribute
  attr_virtual      :real_name
  attr_accessible   :real_name

  # Adding attribute name to :should_be_splitted set (by hand)
  has_attributes_that :should_be_splitted => :real_name

  # Registering callback method
  before_validation :split_attributes
end
```

The result of executing the filter above will be replacement of a string by an array containing
words (each one in a separate element). The `real_name` attribute is a virtual attribute in this example
but it could be real attribute. The result will be written as an array into the same attribute since there
are no destination attributes given. So `'Paul Wolf'` will become `['Paul', 'Wolf']`.

Using limit:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Split

  attr_virtual      :real_name
  splits_attribute  :real_name, :limit => 2
  before_validation :split_attributes
end
```

or without a `split_attributes` keyword:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Split

  attr_virtual      :real_name

  has_attributes_that :should_be_splitted => { :real_name => { :split_limit => 2 } }
  before_validation :split_attributes
end
```

The result of the above example will be the same as the previous one with the difference that any
reduntant elements will be left intact and placed as the last element of an array. So for data:

> `'Paul Thomas Wolf'`

the array will be:

> `[ 'Paul', 'Thomas Wolf' ]`

Another example, let's write results to some attributes:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Split

  attr_virtual      :real_name
  splits_attribute  :real_name, :limit => 2, :into => [ :first_name, :last_name ], :pattern => ' '
  before_validation :split_attributes
end
```

(The `:pattern` is given here but you may skip it if it's a space.)

This will split a value of the `real_name` attribute and place the results in the attributes
called `first_name` and `last_name`, so for:

> `'Paul Thomas Wolf'`

the result will be:

```
  first_name: 'Paul'
  last_name:  'Thomas Wolf'
```

If you remove the limit, then it will be quite different:

```
  first_name: 'Paul'
  last_name:  'Thomas'
```

That's because there are more results than attributes they fit into. You just have to keep in mind
that this filter behaves like the String's split method with the difference when the results are written
into other attributes.

The pattern parameter (`:pattern` when using `split_attributes` or `:split_pattern` when directly
annotating attribute in a set) should be a string.

### Join ###

* Submodule: [`Join`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Join.html)

#### `join_attributes` ####

Joins attributes and places the results into other attributes or into the same attributes as strings.

* Callback method: `join_attributes`
* Class-level helpers:
 * `join_attributes(attribute_name, parameters_hash)` (a.k.a `joint_attribute`)
 * `join_attributes(attribute_name)` (a.k.a `joint_attribute`)
* Class-level helper aliases: `join_attribute`, `joins_attribute`, `joins_attributes`
* Uses set: `:should_be_joined`
* Operates on: strings, arrays of strings
* Uses annotations: yes
 * `join_separator` – a pattern passed to [`join`](http://www.ruby-doc.org/core/Array.html#method-i-join) method (optional)
 * `join_compact` – compact flag; if true then an array is compacted before it's joined (optional)
 * `join_from` – attribute names used as sources for joins (default parameter)
* Parameters' aliases (used with class-level helpers):
 * `join_separator` – `:with`, `:separator`
 * `join_compact` – `:compact`
 * `join_from` – `:from`, `:source`, `:sources`

The join filter uses `join` instance method of the `Array` class to produce single string from multiple strings.
These strings may be values of other attributes (source attributes), values of an array stored in an attribute
or mix of it. If the `:compact` (`:join_compact` in case of manually annotating a set) parameter is given
and it's not `false` nor `nil` then the results are compacted during processing. That means any slices (components)
equals to `nil` are removed just before joining.

If the parameter `:from` (or annotation key `:join_from`) was not given then a currently processed attribute
is treated as a source (it should be an array).

If the joined attribute is a single attribute and its value is an array then all elements of that array will be joined.

Examples:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Join

  attr_virtual            :first_name, :last_name
  attr_accessible         :first_name, :last_name
  joins_attributes_into   :real_name, :from => [ :first_name, :last_name ]
  before_validation       :join_attributes
end
```

you can also switch source with destination:

```ruby
  joins_attributes         [ :first_name, :last_name ] => :real_name
```

or add a descriptive keyword `:into`:

```ruby
  joins_attributes         [ :first_name, :last_name ], :into => :real_name
```

Adding parameters:

```ruby
  joins_attributes         [ :first_name, :last_name ], :into => :real_name, :compact => true
```
or

```ruby
  joins_attributes         [ :first_name, :last_name ] => :real_name, :compact => true
```

or without class-level helper:

```ruby
  has_attributes_that should_be_joined: { :real_name => { :join_from => [ :first_name, :last_name ], :join_compact => true } }
```
