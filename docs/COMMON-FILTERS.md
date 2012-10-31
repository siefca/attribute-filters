
Common filters
--------------

## List of filters ##

* **`capitalize_attributes`**
* **`fully_capitalize_attributes`**
* **`titleize_attributes`**
* **`downcase_attributes`**
* **`upcase_attributes`**
* **`strip_attributes`**
* **`squeeze_attributes`**
* **`squish_attributes`**

See the
[`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
for descriptions of common filtering modules.

### Case ###

* Submodule: [`Case`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Case.html)

#### `capitalize_attributes` ####

Capitalizes attributes.

* Callback method: `capitalize_attributes`
* Class-level helper: `capitalize_attributes(*attribute_names)`
* Uses set: `:should_be_capitalized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  capitalize_attributes   :name
  before_validation       :capitalize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  attributes_that     :should_be_capitalized => [ :name ]
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
* Uses set: `:should_be_fully_capitalized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  fully_capitalize_attributes   :name
  before_validation             :fully_capitalize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  attributes_that     :should_be_fully_capitalized => [ :name ]
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
* Uses set: `:should_be_titleized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  titleize_attributes   :name
  before_validation     :titleize_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  attributes_that     :should_be_titleized => [ :name ]
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
* Uses set: `:should_be_upcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  upcase_attributes   :name
  before_validation   :upcase_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  attributes_that     :should_be_upcased => [ :name ]
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
* Uses set: `:should_be_downcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  downcase_attributes :name
  before_validation   :downcase_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Case

  attributes_that     :should_be_downcased => [ :name ]
  before_validation   :downcase_attributes
end
```

Then:

> `"SOME NAME"`

will become:

> `"some name"`

### Strip ###

* Submodule: [`Strip`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Strip.html)

#### `strip_attributes` ####

Strips attributes of leading and trailing spaces.

* Callback method: `strip_attributes`
* Class-level helper: `strip_attributes(*attribute_names)`
* Uses set: `:should_be_stripped`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Strip

  strip_attributes    :name
  before_validation   :strip_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Strip

  attributes_that     :should_be_stripped => [ :name ]
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
* Uses set: `:should_be_squeezed`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  squeeze_attributes  :name
  before_validation   :squeeze_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  attributes_that     :should_be_squeezed => [ :name ]
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
* Uses set: `:should_be_squished`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  squish_attributes   :name
  before_validation   :squish_attributes
end
```

or

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze

  attributes_that     :should_be_squished => [ :name ]
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
* Uses set: `:should_be_splitted`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: yes
 * `split_pattern` - a pattern passed to [`split`](http://www.ruby-doc.org/core/String.html#method-i-split) method (optional)
 * `split_limit` - a limit passed to `split` method (optional)
 * `split_into` - attribute names used as destinations for parts
 * `split_flatten` - flag that causes resulting array to be flattened
 
If some source attribute is an array or a hash then the filter will recursively traverse it and
operate on each element. The filter works the same way as the `split` method from the `String` class
of Ruby's standard library. If the filter encounters an object which is not a string nor an array or a hash,
it simply leaves it as is.

You can set `:pattern` (`:split_pattern`) and `:limit` (`:split_limit`) arguments passed to
`split` method but note that **a limit is applied to each processed string separately**,
not to the resulting array **(if the processed attribute is an array)**. For instance,
if there is a string containing 3 words (`'A B C'`) and the limit is set to 2 then the last two words
will be left intact and placed in a second element of the resulting array (`['A', 'B C']`).
If the source is an array (`['A', 'B B B B', 'C']`) the result of this operation will be array of arrays
(`[ ['A'], ['B B'], ['C'] ]`); as you can see the limit will be applied to its second element.

If there are no destination attributes defined (`:into` or `:split_into` option) then
the resulting array will be written to a current attribute. If there are destination attributes
given then the resulting array will be written into them (each subsequent element into each next attribute).
The elements that don't fit in the collection are simply ignored.

There is also `flatten` (or `:split_flatten`) parameter that causes the resulting array to be
flattened. Note that it doesn't change how the limits work; they still will be applied but to a single
split results, not to the whole resulting array (in case of array of arrays).

Examples:

```ruby
class User < ActiveRecord::Base
  # Including common filter for splitting
  include ActiveModel::AttributeFilters::Common::Split

  # Registering virtual attribute
  attr_virtual      :real_name
  attr_accessible   :real_name

  # Adding attribute name to :should_be_splitted set
  split_attributes  :real_name

  # Registering callback method
  # Warning: it will be executed each time model object is validated
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
  attributes_that   :should_be_splitted => :real_name

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
  attr_accessible   :real_name
  split_attributes  :real_name, :limit => 2
  before_validation :split_attributes
end
```

or without a `split_attributes` keyword:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Split

  attr_virtual      :real_name
  attr_accessible   :real_name

  attributes_that   :should_be_splitted => { :real_name => { :split_limit => 2 } }
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
  attr_accessible   :real_name
  split_attributes  :real_name, :limit => 2, :into => [ :first_name, :last_name ], :pattern => ' '
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
into other attributes. In that case the limit causes redundant data to be placed in the last element (if a limit
is lower or is the same as the count of destination attributes) and its lack causes some of the resulting data to
be ignored (if there are more slices than receiving attributes).

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
* Uses set: `:should_be_joined`
* Operates on: strings, arrays of strings
* Uses annotations: yes
 * `join_separator` - a pattern passed to [`join`](http://www.ruby-doc.org/core/Array.html#method-i-join) method (optional)
 * `join_compact` - compact flag; if true then an array is compacted before it's joined (optional)
 * `join_from` - attribute names used as sources for joins

The join filter uses `join` instance method of the `Array` class to produce single string from multiple strings.
These strings may be values of other attributes (source attributes), values of an array stored in an attribute
or mix of it. If the `:compact` (`:join_compact` in case of manually annotating a set) parameter is given
and it's not `false` nor `nil` then results are compacted during processing. That means any slices equals to `nil` are 
removed.

If the parameter `:from` (or annotation key `:join_from`) was not given then a currently processed attribute
is treated as a source (it should be an array).

Examples:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Join

  attr_virtual            :first_name, :last_name
  attr_accessible         :first_name, :last_name
  join_attributes_into    :real_name, :from => [ :first_name, :last_name ]
  before_validation       :join_attributes
end
```

you can also switch source with destination:

```ruby
  join_attributes         [ :first_name, :last_name ] => :real_name
```

or add a descriptive keyword `:into`:

```ruby
  join_attributes         [ :first_name, :last_name ], :into => :real_name
```
