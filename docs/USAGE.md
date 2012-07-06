Usage of Attribute Filters
==========================

Attribute sets
--------------

Attribute set is a set of attribute names. It's like an array
or, to be exact, like a set (a hash that can only have true values
assigned to elements in order to just know whether the key exists or not).

Attribute sets have simple function; **they group attribute names**. What you
can do with that? For example you can use it to perform some tasks
on all attributes that are listed in a set.

### Data structures ###

Attribute sets are instances of
[`ActiveModel::AttributeSet`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeSet)
class. They are stored within your model as [class instance variables](http://blog.codegram.com/2011/4/understanding-class-instance-variables-in-ruby).
You cannot and should not interact with them directly
but by using dedicated class methods that are available in your models.
These methods will allow you to read or write some data from/to attribute sets.

Attribute Filters are using `AttributeSet` objects
not just to store internal data but also to interact
with other parts of a program. So whenever there is
a method that returns a set of attributes or even
a set of set names, the returned value will probably
be an instance of the class `AttributeSet`.

Note that when sets are returned the convntion is that:

  * **attribute names are strings**
  * **set names are symbols**

### Defining the attribute sets ###

First thing that should be done when using the Attribute Filters
is defining the sets of attributes in models.

#### `attribute_set(set_name => attr_names)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) method allows to **create or update a set**.

Example:

```ruby
class User < ActiveRecord::Base

  attributes_that should_be_stripped:     [ :username, :email, :real_name ]
  attributes_that should_be_downcased:    [ :username, :email ]
  attributes_that should_be_capitalized:  [ :real_name ]

end
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that`, `attributes_that_are`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`, `attributes_for`,  
    `are_attributes`, `are_attributes_for`, `attributes_set`, `properties_that`   

#### `filter_attribute(attr => set_names)` ####

You may prefer the alternative syntax, that **uses attribute names**
as primary arguments, but has exactly the same effect as the `attribute_set`.

The [`filter_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:filter_attribute)
(a.k.a `the_attribute`) method also lets you create or update a set, just the arguments order is reversed (attribute name goes first).

Example:

```ruby
class User < ActiveRecord::Base

  the_attribute real_name:  [ :should_be_stripped, :should_be_capitalized ]
  the_attribute username:   [ :should_be_stripped, :should_be_downcased   ]
  the_attribute email:      [ :should_be_stripped, :should_be_downcased   ]

end
```

Instead of `filter_attribute` you may also use one of the aliases:

  * `filtered_attribute`, `the_attribute`, `add_attribute_to_set`,    
    `add_attribute_to_sets`, `attribute_to_set`, `filtered_attributes`

#### Mixing the syntaxes ####

You can mix both syntaxes given in the examples before.
You can also use regular arguments instead of hashes to create sets:

```ruby
class User < ActiveRecord::Base

  attributes_that :should_be_stripped, :username, :email, :real_name

  the_attribute :real_name, :should_be_capitalized
  the_attribute :username,  :should_be_downcased
  the_attribute :email,     :should_be_downcased

end
```

### Querying sets in models ###

When your attribute sets are defined then you can use couple
of class methods to query them, e.g. to check their contents.

#### `attribute_set(set_name)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) class method called with a single argument **returns the attribute set
of the given name**. It will always return AttributeSet object, even if there is not set of the given name
(in that case the resulting set will be empty).

Example:

```
  User.attributes_that(:should_be_stripped) - User.attributes_that(:should_be_downcased)
  => #<ActiveModel::AttributeSet: {"real_name"}>
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that`, `attributes_that_are`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`, `attributes_for`,  
    `are_attributes`, `are_attributes_for`, `attributes_set`, `properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_sets)
class method returns a hash containing **all the defined attribute sets** indexed by their names.

Example:

```
  User.attribute_sets.keys
  => [:should_be_downcased, :should_be_stripped, :should_be_capitalized]

  User.attribute_sets.first
  => [:should_be_downcased,  #<ActiveModel::AttributeSet: {"username", "email"}>]
```

Note that the returned hash will have a default value set to instance of the `AttributeSet`.
If you'll try to get the value of an element that doesn't exist **the empty set will be returned**.
It won't return the exact internal hash but a duplicate.

Instead of `attribute_sets` you may also use one of the aliases:

  * `attributes_sets`, `properties_sets`

#### `attribute_set` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) class method called without any arguments is a wrapper that calls `attribute_sets` which
returns a hash containing **all the defined attribute sets**.

#### `filter_attribute(attribute_name)` ####

The [`filter_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:filter_attribute)
(a.k.a `the_attribute`) class method called with a single argument
is used for checking **what are the sets that the attribute belongs to**.
It will always return AttributeSet object, even if there is no attribute of the given name
(in that case the resulting set will be empty).

Example:

```
 User.the_attribute :real_name
 => #<ActiveModel::AttributeSet: {:should_be_stripped, :should_be_capitalized }>
```

Instead of `filter_attribute` you may also use one of the aliases:

  * `filtered_attribute`, `the_attribute`, `add_attribute_to_set`,    
    `add_attribute_to_sets`, `attribute_to_set`, `filtered_attributes`

#### `attributes_to_sets` ####

The [`attributes_to_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attributes_to_sets)
class method returns a hash containing **all filtered attributes and arrays of sets**
that the attributes belong to. The hash is indexed by attribute names.
(Filtered means that they belong to some sets.)

Example:

```
  User.attributes_to_sets.keys
  => ["real_name", "username", "email"]
```

Note that the returned hash will have a default value set to instance of the `AttributeSet`.
If you'll try to get the value of an element that doesn't exist **the empty set will be returned**.

Instead of `attributes_to_sets` you may also use one of the aliases:

  * `attribute_sets_map`

#### `filter_attribute` ####

The [`filter_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:filter_attribute)
(a.k.a `the_attribute`) class method called without any arguments
is a wrapper that calls `attributes_to_sets` which returns
a hash containing **all filtered attributes and arrays of sets**
that the attributes belong to.


### Querying sets in objects ###

It is possible to access attribute sets from within the ActiveModel (or ORM, like ActiveRecord) objects.
To do that you may use instance methods that are designed for that purpose.

#### `attribute_set(set_name)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_set)
(a.k.a `attributes_that`) method called with a single argument **returns the attribute set
of the given name**. It won't return the exact set object but a duplicate.
It will always return AttributeSet object, even if there is not set of the given name
(in that case the resulting set will be empty).

Example:

```
  User.first.attributes_that(:should_be_stripped)
  =>  #<ActiveModel::AttributeSet: {"real_name", "username", "email"}>
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that_are`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`,      
    `attributes_for`, `are_attributes`, `are_attributes_for`, `attributes_set`,            
    `properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_sets)
method returns a hash containing **all the defined attribute sets** indexed by their names.
It won't return the exact internal hash but a duplicate.

Example:

```
  User.first.attribute_sets.keys
  => [:should_be_downcased, :should_be_stripped, :should_be_capitalized]

  User.first.attribute_sets.first
  => [:should_be_downcased,  #<ActiveModel::AttributeSet: {"username", "email"}>]
```

Note that the returned hash will have a default value set to instance of the `AttributeSet`.
If you'll try to get the value of an element that doesn't exist **the empty set will be returned**.

Instead of `attribute_sets` you may also use one of the aliases:

  * `attributes_sets`, `properties_sets`

#### `filtered_attribute(attribute_name)` ####

The [`filtered_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:filtered_attribute)
(a.k.a `the_attribute`) method called with a single argument is used for checking
**what are the sets that the attribute belongs to**. It won't return the exact set object but a duplicate.
It will always return AttributeSet object, even if there is no attribute of the given name
(in that case the resulting set will be empty).

Example:

```
 User.first.the_attribute :real_name
 => #<ActiveModel::AttributeSet: {:should_be_stripped, :should_be_capitalized }>
```

Instead of `filtered_attribute` you may also use one of the aliases:

  * `the_attribute`, `is_the_attribute`, `are_attributes`,     
    `are_the_attributes`

#### `attributes_to_sets` ####

The [`attributes_to_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attributes_to_sets)
method returns a hash containing **all filtered attributes and arrays of sets**
that the attributes belong to. The hash is indexed by attribute names.

Example:

```
  User.first.attributes_to_sets.keys
  => ["real_name", "username", "email"]
```

Note that the returned hash will have a default value set to instance of the `AttributeSet`.
It won't return the exact internal hash but a duplicate.
If you'll try to get the value of an element that doesn't exist **the empty set will be returned**.

Instead of `attributes_to_sets` you may also use one of the aliases:

  * `attribute_sets_map`

Attribute filters
-----------------

Having attribute sets defined we can make use of them in many different ways.
One is filtering attributes, either by hand or with a little help of ORM
[callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html#callbacks-overview).
The Attribute Filters library brings some DSL methods to make that task easy.

First of all, it won't create any callbacks for you nor register them in your models.
You have to create filtering methods manually and call them (or add their names) in the
right places. That way you still have control over the filtering process and its order.
The thing that is different with Attribute Filters is that you can create filtering
methods without reffering to particular attributes but to sets defined earlier.

Example:

```ruby
class User < ActiveRecord::Base

  # Defining attribute sets

  the_attribute real_name:  [ :should_be_stripped, :should_be_capitalized ]
  the_attribute username:   [ :should_be_stripped, :should_be_downcased   ]
  the_attribute email:      [ :should_be_stripped, :should_be_downcased   ]

  # Registering filtering callback methods

  before_validation :strip_names
  before_validation :downcase_names
  before_validation :capitalize_names

  # Defining filtering methods

  def downcase_names
    filter_attributes_that :should_be_downcased do |atr|
      atr.mb_chars.downcase.to_s
    end
  end

  def capitalize_names
    filter_attributes_that :should_be_capitalized do |atr|
      atr.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
    end
  end

  def strip_names
    for_attributes_that(:should_be_stripped) { |atr| atr.strip! }
  end

end
```

What we see here are filtering clauses that are responsible
for altering attribute values: `for_attributes_that` and
`filter_attributes_that`.

#### `filter_attrs_from_set(set_name,...)` ####

The [`filter_attrs_from_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:filter_attrs_from_set)
(a.k.a `filter_attributes_that`) method is used for **altering values of all attributes that belong to the given set**.
It takes optional arguments and a block. The result of evaluating a block will become a new value for a processed
attribute. Optional arguments will be passed as the last arguments of a block.

By default only existing, changed and non-blank attributes are processed.
You can change that behavior by adding a flags as the first arguments:

  * `:process_blank` – tells to also process attributes that are blank (empty or `nil`)
  * `:process_all` - tells to process all attributes, not just the ones that has changed
  * `:no_presence_check` – tells not to check for existence of each processed attribute when processing
    all attributes; increases performance but you must care about putting only the existing attributes into sets

Example:

```
  class User
    attributes_that should_be_lolized: [ :username ]
    before_validation :lolize

    def lolize
      filter_attributes_that(:should_be_lolized, "lol") do |attribute_value, set_name, attribute_name, *args|
        [attribute_value, set_name.to_s, attribute_name, *args.flatten].join('-')
      end
    end
  end

  u = User.new
  u.username = 'john'
  u.valid?
  u.username
  => "john-should_be_lolized-username-lol"
```

Instead of `filter_attrs_from_set` you may also use one of the aliases:

  * `attribute_filter_for_set`, `filter_attributes_which`,       
    `filter_attributes_that`, `filter_attributes_that_are`, `filter_attributes_which_are`,      
    `alter_attributes_which`, `alter_attributes_that`, `alter_attributes_that_are`, `alter_attributes_which_are`

#### `for_each_attr_from_set(set_name,...)` ####

The [`for_each_attr_from_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:for_each_attr_from_set)
(a.k.a `for_attributes_that`) method is used for **iterating over all attributes that belong to the given set**.
It takes optional arguments and a block. The result of evaluating the given block is ignored
but you can interact with the attribute object from within a block.
Optional arguments will be passed as the last arguments of a block.

By default only existing, changed and non-blank attributes are processed.
You can change that behavior by adding a flags as the first arguments:

  * `:process_blank` – tells to also process attributes that are blank (empty or `nil`)
  * `:process_all` - tells to process all attributes, not just the ones that has changed
  * `:no_presence_check` – tells not to check for existence of each processed attribute when processing
    all attributes; increases performance but you must care about putting only the existing attributes into sets

Example:

```
  class User
    attributes_that should_be_lolized: [ :username ]
    before_validation :lolize

    def lolize
      for_attributes_that(:should_be_lolized, "lol") do |attribute_object, set_name, attribute_name, *args|
        attribute_object << '-' << [set_name.to_s, attribute_name, *args.flatten].join('-')
      end
    end
  end

  u = User.new
  u.username = 'john'
  u.valid?
  u.username
  => "john-should_be_lolized-username-lol"
```

Instead of `filter_attrs_from_set` you may also use one of the aliases:

  * `attribute_call_for_set`, `call_attrs_from_set`,       
    `for_attributes_which`, `for_attributes_that`, `for_attributes_that_are`, `for_attributes_which_are`

### Syntactic sugar for filters ###

(to be written)

Predefined filters
------------------

(to be written)


Custom applications
-------------------

(to be written)

