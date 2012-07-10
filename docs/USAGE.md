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

Attribute Filters are using `AttributeSet` instances
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
(a.k.a `attributes_that`) class method allows to **create or update a set**.

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
(a.k.a `the_attribute`) class method also lets you create or update a set, just the arguments order is reversed
(attribute name goes first).

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
of the given name**. It will always return an `AttributeSet` instance, even if there is not set of the given name
(in that case the resulting set will be empty).

Example:

```ruby
  User.attributes_that(:should_be_stripped) - User.attributes_that(:should_be_downcased)
  # => #<ActiveModel::AttributeSet: {"real_name"}>
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that`, `attributes_that_are`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`, `attributes_for`,  
    `are_attributes`, `are_attributes_for`, `attributes_set`, `properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_sets)
class method returns a hash containing **all the defined attribute sets** indexed by their names.

Example:

```ruby
  User.attribute_sets.keys
  # => [:should_be_downcased, :should_be_stripped, :should_be_capitalized]

  User.attribute_sets.first
  # => [:should_be_downcased,  #<ActiveModel::AttributeSet: {"username", "email"}>]
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
It will always return an `AttributeSet` instance, even if there is no attribute of the given name
(in that case the resulting set will be empty).

Example:

```ruby
 User.the_attribute :real_name
 # => #<ActiveModel::AttributeSet: {:should_be_stripped, :should_be_capitalized }>
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

```ruby
  User.attributes_to_sets.keys
  # => ["real_name", "username", "email"]
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
It will always return an `AttributeSet` instance, even if there is not set of the given name
(in that case the resulting set will be empty).

Example:

```ruby
  User.first.attributes_that(:should_be_stripped)
  # =>  #<ActiveModel::AttributeSet: {"real_name", "username", "email"}>
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that_are`, `from_attributes_that`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`,      
    `attributes_for`, `are_attributes`, `are_attributes_for`, `attributes_set`,            
    `properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_sets)
method returns a hash containing **all the defined attribute sets** indexed by their names.
It won't return the exact internal hash but a duplicate.

Example:

```ruby
  User.first.attribute_sets.keys
  # => [:should_be_downcased, :should_be_stripped, :should_be_capitalized]

  User.first.attribute_sets.first
  # => [:should_be_downcased,  #<ActiveModel::AttributeSet: {"username", "email"}>]
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

```ruby
 User.first.the_attribute :real_name
 # => #<ActiveModel::AttributeSet: {:should_be_stripped, :should_be_capitalized }>
```

Instead of `filtered_attribute` you may also use one of the aliases:

  * `the_attribute`, `is_the_attribute`, `are_attributes`,     
    `are_the_attributes`

#### `attributes_to_sets` ####

The [`attributes_to_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attributes_to_sets)
method returns a hash containing **all filtered attributes and arrays of sets**
that the attributes belong to. The hash is indexed by attribute names.

Example:

```ruby
  User.first.attributes_to_sets.keys
  # => ["real_name", "username", "email"]
```

Note that the returned hash will have a default value set to instance of the `AttributeSet`.
It won't return the exact internal hash but a duplicate.
If you'll try to get the value of an element that doesn't exist **the empty set will be returned**.

Instead of `attributes_to_sets` you may also use one of the aliases:

  * `attribute_sets_map`
  
### Syntactic sugar for queries ###

Querying attribute sets may be even more sweet when you add some syntactic sugar
provided by the Attribute Filters. The methods used for querying make use of internal
proxy classes that provide additional DSL keywords that can be used to express
the program logic. These are present when querying **in an instance**, not in a model
class.

The additional features depend of query type and are different for querying
atrribute sets and different for querying attributes for associated sets. In
practice there are two groups of methods with two sets of DSL features.

First group (querying attribute sets):

* [`attribute_set`](#attribute_set_set_name_0) and aliases
* [`attributes_to_filter`](#attributes_to_filter_set_name_____)

Second group (querying attributes for sets they belong to):

* [`filtered_attribute`](#filtered_attribute_attribute_name_) and aliases

#### Querying attribute sets ####

Querying attribute sets uses two instance methods available
in your models:

* [`attribute_set`](#attribute_set_set_name_0) and aliases
* [`attributes_to_filter`](#attributes_to_filter_set_name_____)

The output of calling these methods is an `AttributeSet` instance
wrapped within a transparent proxy class instance
([`AttributeSet::Query`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeSet/Query)).

##### Eager wrapping #####

Whenever an output generated by that methods
is a kind of `AttributeSet` **the result is wrapped again**
in order to help you in creating nice looking method call chains like:

```ruby
  User.first.attributes_that(:should_be_stripped).sort.list.present?
```

##### Neutral methods #####

* **`are`**
* **`is`**
* **`be`**
* **`should`**

You can attach **"neutral" methods** to the output of `attribute_set`
or `attributes_to_filter` and the same object will be returned
(equivalent to `self`).

Example:

```ruby
  User.first.attributes_that(:should_be_stripped).present?
  # => true

  User.first.attributes_that(:should_be_stripped).are.present?
  # => true
```

##### Presence selectors #####

* **`all`**
* **`any`**
* **`none`**
* **`one`**

The example above was just the check to see if the returned set is empty or not.
How about checking if all of the attributes that belong to a set are present
(meaning their values)?

Let's do it without any fancy DSL methods:

```ruby
  u = User.first
  u.attributes_that(:should_be_stripped).all? do |attribute_name|
    u.send(attribute_name).present?
  end
  # => false
```

Now the same task but with some sugar:

```ruby
  User.first.attributes_that(:should_be_stripped).all.present?
  # => false
```

How it works? Whenever `all`, `any`, `one`
or `none` is called on an output of the set querying methods
the call is forwarded to the `all?`, `any?`, `one?` or `none?` method
with passed a block in which the next method given in chain is invoked
for a value of each attribute from a set. The additional arguments,
if any, are also forwarded and passed to the method called within a block.
Just imagine that:

```ruby
  attributes_that(:should_be_stripped).all.METHOD(ARGUMENTS)
```

becomes:

```ruby
  attributes_that(:should_be_stripped).all? { |attribute| attribute METHOD(ARGUMENTS) }
```

Another example, but with `any`:

```ruby
  User.first.attributes_that(:should_be_stripped).any.present?
  # => true
```

##### Elements selectors #####

* **`list`**
* **`show`**

There are two more DSL methods: `list` and `show` (both doing the same thing).
They forward a call the same way as the presence selectors do but the called
method is not `any?` or `all?` but `select`. For instance:

```ruby
  u = User.first
  u.attributes_that(:should_be_stripped).list.present?
  
  # => #<ActiveModel::AttributeSet: {"username", "email"}> 
```

is equivalent to:

```ruby
  u = User.first
  u.attributes_that(:should_be_stripped).select do |atr|
    u.atr.present?
  end
  
  # => #<ActiveModel::AttributeSet: {"username", "email"}> 
```

#### Querying attributes for set names ####

Querying attributes to know sets they belong to uses one
instance method available in your models:

* [`filtered_attribute`](#filtered_attribute_attribute_name_) and aliases

The output of calling this method is an `AttributeSet` instance
containing **attribute set names** (instead of attribute names),
wrapped within a transparent proxy class instance
([`AttributeSet::AttrQuery`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeSet/AttrQuery)).

##### Neutral methods #####

* **`are`**
* **`is`**
* **`one`**
* **`is_one`**
* **`in`**
* **`list`**
* **`be`**
* **`should`**
* **`the`**
* **`a`**
* **`sets`**
* **`in_set`**
* **`in_sets`**
* **`in_a_set`**
* **`belongs_to`**

You can attach **"neutral" methods** to the output of `filtered_attribute`
(a.k.a `the_attribute`) instance method and the same object will be returned
(equivalent to `self`).

Example:

```ruby
  User.first.the_attribute(:username).list.sets
  # => #<ActiveModel::AttributeSet: {:should_be_downcased, :should_be_stripped}>
```

##### Set membership testing #####

* **:belongs_to?**
* **`in?`**
* **`in_set?`**
* **`in_a_set?`**
* **`in_the_set?`**
* **`the_set?`**
* **`set?`**
* **`is_one_that?`**
* **`one_that?`**
* **`that?

These methods allow to test if the attribute belongs to the given
attribute set or sets. You may consider the methods above aliases
of the `include?`. The one difference is that all the given arguments
are changed to symbols.

Example:

```ruby
  User.first.the_attribute(:username).is.in.set.that?(:should_be_stripped)
  # => true

  User.first.the_attribute(:username).belongs_to.set.that?(:should_be_stripped)
  # => true
```

##### Set membership querying #####

Membership querying has different syntax from simple testing.
It uses set name with the question mark attached to it.

Example:

```ruby
  User.first.the_attribute(:username).should_be_stripped?
  # => true
```

To use that syntax you have to be sure that there is no already
defined method for AttributeSet object which name ends
with question mark. Otherwise you may get false positives
or a strange errors when trying to test if attribute belongs
to a set. The real method call will override your check.

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

### Filtering attributes ###

Filtering attributes basically means calling a proper
method that will collect the attributes (matching certain
criteria and belonging to the given set) and call some code block
used that will either produce their new values or just call
some method on each of them.

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

```ruby
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
  # => "john-should_be_lolized-username-lol"
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

```ruby
  class User
    attributes_that should_be_lolized: [ :username ]
    before_validation :lolize

    def lolize
      for_attributes_that(:should_be_lolized, :process_blank, "lol") do |attribute_object, set_name, attribute_name, *args|
        attribute_object << '-' << [set_name.to_s, attribute_name, *args.flatten].join('-')
      end
    end
  end

  u = User.new
  u.username = 'john'
  u.valid?
  u.username
  # => "john-should_be_lolized-username-lol"
```

Instead of `filter_attrs_from_set` you may also use one of the aliases:

  * `attribute_call_for_set`, `call_attrs_from_set`,       
    `for_attributes_which`, `for_attributes_that`, `for_attributes_that_are`, `for_attributes_which_are`

#### `attributes_to_filter(set_name,...)` ####

The [`attributes_to_filter`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attributes_to_filter)
method is used for **getting the attributes that should be filtered**.
This is a core method used by other filtering methods to establish a collection of attributes
to be processed but you can use it on your own. It returns an `AttributeSet` instance containing
attribute names that match the given criteria (by default: that are in a set of the given name,
that are present and that have changed lately).

The method takes one manatory argument (`set_name`) and two optional arguments (`process_all` and `no_presence_check`)
that can be `true` or `false` (default). The first optional argument (`process_all`),
when set to `true`, forces method to return also the attributes that haven't changed lately.
By default the result will be narrowed to the attributes that have changed and haven't been saved yet.
The second optional argument (`no_presence_check`) will tell the method to omit the presence check
for each attribute. By default only the attributes that are real attributes (are present
in `attributes` hash) are collected. This mehtod does not check the value of attributes.

Example:

```ruby
  u = User.first
  u.email = "some@example.com"
  u.attributes_to_filter(:should_be_stripped)
  
  # => #<ActiveModel::AttributeSet: {"email"}> 
```

In the example above only the email attribute was listed since it would be filtered
if the filtering operation occured.

### Filtering virtual attributes ###

There are cases that virtual attributes (the ones that does not really exist in a database)
are to be filtered. By default it won't happen since all the filtering methods assume
the presence of any processed attribute as "the real" attribute. There are three ways
to overcome that problem.

First (the messy one) is to add/update a virtual attribute in `attributes` hash each time
a setter for your attribute is called. It interacts with the Rails internals so
use it at your own risk. You should also register attribute as changed if any changes
are made on it. To do that look at your ORM's documentation and see
[`ActiveModel::Dirty`](http://api.rubyonrails.org/classes/ActiveModel/Dirty.html).

The second way is to pass the `:no_presence_check` and `process_all` flags to the filtering method.
Be aware that by doing that you take full responsibility for attribute set defined in your model.
If you put a name of nonexistent attribute to the set then later you may get ugly error.

The third way is to use `treat_attributes_as_real` (or simply `treat_as_real`) clause in your model
(available from version 1.2.0 of Attribute Filters). That's **the preferred one**.

Just add your virtual attributes to the model like that:

```ruby
  class User
    treat_as_real :some, :virtual, :attributes
  end
```

Be aware that the virtual attributes will always be filtered regardless of `process_all` flag,
since there is no way to know whether they have changed or not. If you are somehow updating
`changes` (or `changed_attributes` hash) on your own then you can modify that behavior
for specific model by putting `filter_virtual_attributes_that_have_changed` keyword into it:

```ruby
  class User
    filter_virtual_attributes_that_have_changed
    treat_as_real :some, :virtual, :attributes
  end
```

The presence of virtual attributes is tested by checking
if both, a setter and a getter, methods exist,
unless the `no_presence_check` flag is passed
to a filtering method.

Predefined filters
------------------

Predefined filters are ready-to-use methods
for filtering attributes. You just have to call them
or pass their names to callback hooks.

To use predefined filters you have to manually
include the [`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
module.

Here is a list of the predefined filtering methods:

* **`capitalize_attributes`**
* **`fully_capitalize_attributes`**
* **`downcase_attributes`**
* **`upcase_attributes`**
* **`strip_attributes`**

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  the_attribute user:   [:should_be_stripped, :should_be_downcased  ]
  the_attribute email:  [:should_be_stripped, :should_be_downcased  ]
  the_attribute name:   [:should_be_stripped, :should_be_downcased, :should_be_fully_capitalized ]
  
  before_validation :strip_attributes
  before_validation :downcase_attributes
  before_validation :fully_capitalize_attributes
end
```

Custom applications
-------------------

You may want to use attribute sets for custom logic, not just for the filtering
purposes. For example, you may have some set of attributes that all have to
exist for a user to make deals. Then you may have some method that checks if
user is able to trade by testing the presence of attributes from the defined set.

Example:

```ruby
class User < ActiveRecord::Base

  attributes_that_are required_to_trade: [ :username, :email, :real_name, :address, :account ]

  def is_able_to_trade?
    are_attributes_that_are(:required_to_trade).all.present?
  end

  def attributes_missing_to_trade
    attributes_that_are(:required_to_trade).list.blank?
  end

end
```

See also
--------

* [Whole documentation](http://rubydoc.info/gems/attribute-filters/)
* [GEM at RubyGems](https://rubygems.org/gems/attribute-filters)
* [Source code](https://github.com/siefca/attribute-filters/tree)
