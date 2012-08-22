Usage of Attribute Filters
==========================

Attribute sets
--------------

Attribute set is a set of attribute names. It's like an array
or, to be exact, like a set (a hash that can only have true values
assigned to elements in order to just know whether the key exists or not).

Attribute sets have simple function; **they group attribute names**. What can
you do with that? For example you can use it to perform some tasks
on all attributes that are listed in a set.

### Data structures ###

Attribute sets are instances of
[`ActiveModel::AttributeSet`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeSet)
class. You can create and update sets freely and store them wherever you want,
but when it comes to models then (at the class-level) you can (and you should) rely
on a storage that is already prepared to handle sets.

The attribute sets assigned to models are stored as [class instance variable](http://blog.codegram.com/2011/4/understanding-class-instance-variables-in-ruby).
**You cannot and should not interact with that storage directly**
but by using dedicated class methods that are available in your models.
These methods will allow you to read or write some data from/to global attribute sets.

Attribute Filters are using `AttributeSet` instances
not just to store internal data but also to interact
with other parts of a program. So whenever there is
a method that returns a set of attributes or even
a set of set names, the returned value will probably
be an instance of the class `AttributeSet`.

Note that when sets are returned the convention is that:

  * **attribute names are strings**
  * **set names are symbols**

Also note that once you create a set that is bound to your model you cannot
remove elements from it and any query returning its contents will give you
a copy. That's because **model-bound attribute sets should be considered
a part of the interface**.

### Defining the attribute sets ###

First thing that should be done when using the Attribute Filters
is defining the sets of attributes in models.

You can also create local sets (using `ActiveModel::AttributeSet.new`)
or a local sets with extra syntactic sugar (using `ActiveModel::AttributeSet.new`)
but in real-life scenarios you should first create some model-bound sets that
can be later used by filters and by your own methods.
 
#### `attribute_set(set_name => attr_names)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) class method allows to **create or update a set** that will be
tied to a model.

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

When your "global" attribute sets are defined, you can use couple
of class methods to query them.

#### `attribute_set(set_name)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) class method called with a single argument **returns the attribute set
of the given name**. It will always return the instance of `AttributeSet` class, even if there
is no set registered under the given name (in that case the resulting set will be empty).

Example:

```ruby
  User.attributes_that(:should_be_stripped) - User.attributes_that(:should_be_downcased)
  # => #<ActiveModel::AttributeSet: {"real_name"}>
```

Note that the returned set will be a copy of the original set stored within your model.

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

Note that the returned sets will be copies of the original sets stored within your model.

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

### Querying sets in model objects ###

It is possible to access attribute sets from within the ActiveModel (or ORM, like ActiveRecord) objects.
To do that you may use instance methods that are designed for that purpose.

#### `attribute_set` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_set)
instance method called withount an argument **returns the attribute set object containing all attributes known in a current object**.

Example:

```ruby
  User.first.attribute_set
  # =>  #<ActiveModel::AttributeSet: {"id", "username", "email", "password", "language", "created_at", "updated_at"}>
```

It works the same as the `all_attributes` method.

#### `attribute_set(set_name)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_set)
(a.k.a `attributes_that`) instance method called with a single argument **returns a copy of the attribute set
of the given name**. It won't return the exact set object but a duplicate.
It will always return an `AttributeSet` instance, even if there is no set of the given name defined for a model
(in that case the resulting set will be empty).

Example:

```ruby
  User.first.attributes_that(:should_be_stripped)
  # =>  #<ActiveModel::AttributeSet: {"real_name", "username", "email"}>
```

The returned object in transparently wrapped in a proxy class instance that allows you
to apply additional methods and keywords to it. See the section
['Syntactic sugar for queries'](http://rubydoc.info/gems/attribute-filters/file/docs/USAGE.md#Syntactic_sugar_for_queries)
for more info.

There are also variants of this method that differ in a kind of taken argument:

* `attribute_set(set_object)`

> Allows to wrap an existing attribute set instance (e.g. created locally) with transparent proxy instance.
> The resulting object will look like the same set but will be decorated with additional syntactic sugar.

* `attribute_set(any_object)`

> Allows to create local set that will be initialized with the given object (usually an array) that may not
> be a `String`, a `Symbol` or an `AttributeSet` (these are reserved for the variants above). The resulting
> object (a new `AttributeSet` instance) is also wrapped in a proxy.

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_that_are`, `from_attributes_that`, `are_attributes_that_are`, `from_attributes_that_are`,   
    `within_attributes_that_are`, `attributes_that`, `attributes_are`,      
    `attributes_for`, `are_attributes`, `are_attributes_for`, `attributes_set`,            
    `properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_sets)
method returns a hash containing **all the defined attribute sets** indexed by their names.
It won't return the exact internal hash but a duplicate and every set within it will also be a duplicate
of the original one.

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

#### `all_attributes` ####

The [`all_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_attributes)
method **returns the attribute set containing all known attributes**.

Example:

```ruby
  User.first.all_attributes
  # =>  #<ActiveModel::AttributeSet: {"id", "username", "email", "password", "language", "created_at", "updated_at"}>
```

Be aware that this method requires that the used ORM has `attributes` data structure available for any model object.

Instead of `all_attributes` you may also use the alias:

  * `all_attributes_set`
  
or call the instance method `attribute_set` without arguments.

#### `all_accessible_attributes` ####

The [`all_accessible_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_accessible_attributes)
method **returns the attribute set containing all accessible attributes**.

Example:

```ruby
  User.first.all_accessible_attributes
  # =>  #<ActiveModel::AttributeSet: {"username", "email", "language"}> 
```

Be aware that this method requires that the used ORM has `accessible_attributes` data structure available for any model class.

Instead of `all_accessible_attributes` you may also use the alias:

  * `accessible_attributes_set`

#### `all_protected_attributes` ####

The [`all_protected_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_protected_attributes)
method **returns the attribute set containing all protected attributes**.

Example:

```ruby
  User.first.all_protected_attributes
  # =>  #<ActiveModel::AttributeSet: {"id"}> 
```

Be aware that this method requires that the used ORM has `protected_attributes` data structure available for any model class.

Instead of `all_protected_attributes` you may also use the alias:

  * `protected_attributes_set`

#### `all_inaccessible_attributes` ####

The [`all_inaccessible_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_inaccessible_attributes)
method **returns the attribute set containing all inaccessible attributes**. Inaccessible attributes are attributes
that aren't listed as accessible, which includes protected attributes and attributes for which the `attr_accessible` clause
wasn't used.

Example:

```ruby
  User.first.all_inaccessible_attributes
  # =>  #<ActiveModel::AttributeSet: {"id", "password", "created_at", "updated_at"}> 
```

Be aware that this method requires that the used ORM has `accessible_attributes` data structure available for any model class.

Instead of `all_inaccessible_attributes` you may also use the alias:

  * `inaccessible_attributes_set`

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

#### `valid?` and `invalid?` ####

Validation helpers are used to test if the attributes present in a set
are valid. When `valid?` is called then **all** attributes from a set
must be valid for the method to return `true`. When `invalid?` is called
then **any** invalid attribute will cause the expression to return `true`.

Be aware that calling one of these methods will run validation process
on an instance of a model. Besides, your ORM should have the `errors`
hash available in order to use it (Active Record has it).

Example:

```ruby
  u = User.first
  u.attributes_that(:should_be_stripped).valid?
  # => true
  u.attributes_that(:should_be_stripped).invalid?
  # => false
```

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

* [`attribute_set`](#attribute_set0) and aliases
* [`attribute_set(set_name)`](#attribute_set_set_name_1) and aliases
* [`attributes_to_filter`](#attributes_to_filter_set_____)

Second group (querying attributes for sets they belong to):

* [`filtered_attribute`](#filtered_attribute_attribute_name_) and aliases

#### Querying attribute sets ####

Querying attribute sets uses two instance methods available
in your models:

* [`attribute_set`](#attribute_set0) and aliases
* [`attribute_set(set_name)`](#attribute_set_set_name_1) and aliases
* [`attributes_to_filter`](#attributes_to_filter_set_____)

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
    u.public_send(attribute_name).present?
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

##### Validation helpers #####

* **`valid?`**
* **`invalid?`**

Syntactic sugar for validation helpers is used when calls to these methods
are combined with selectors described above (presence selectors and elements selectors).

Examples:

```ruby
  u = User.first
  
  u.attributes_that(:should_be_stripped).all.valid?
  # => true
  
  u.attributes_that(:should_be_stripped).list.valid?
  # => #<ActiveModel::AttributeSet: {"username", "email"}>
```

Be aware that calling these methods causes model object to be validated. The required condition
to use these methods is the ORM that has `errors` hash (Active Record has it).

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

* **`belongs_to?`**
* **`in?`**
* **`in_set?`**
* **`in_a_set?`**
* **`in_the_set?`**
* **`the_set?`**
* **`set?`**
* **`is_one_that?`**
* **`one_that?`**
* **`that?`**

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

##### Set accessibility querying #####

* **`accessible?`**
* **`inaccessible?`**
* **`protected?`**
* **`is_accessible?`**
* **`is_inaccessible?`**
* **`is_protected?`**

The methods above allow to you to test if certain attribute is accessible, inaccessible or protected.

Examples:

```ruby
  u = User.first
  u.the_attribute(:id).is.accessible?
  # => false
  u.the_attribute(:id).is.protected?
  # => true
  u.the_attribute(:id).is.inaccessible?
  # => true
```

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
criteria and belonging to the given set) and calling some code block
that will either produce new values or just call some method on each
of current attribute value and name.

#### `filter_attrs_from_set(set_name,...)` ####

The [`filter_attrs_from_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:filter_attrs_from_set)
(a.k.a `filter_attributes_that`) method is used for **altering values of all attributes that belong to the given set**.
It takes optional arguments and a block. The result of evaluating a block will become a new value for a processed
attribute. Optional arguments will be passed as the last arguments of a block.

The evaluated block can make use of the following arguments that are passed to it:

* `attribute_value` [Object] - current attribute value that should be altered
* `attribute_name` [String] - a name of currently processed attribute
* `set_object` [Object] - currently processed set that attribute belongs to
* `set_name` [Symbol] - a name of the processed attribute set
* `args` [Array] - an optional arguments passed to the method

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
      filter_attributes_that(:should_be_lolized, "lol") do |attribute_value, attribute_name, set_object, set_name, *args|
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

You can pass a set object (`AttributeSet` instance) instead of set name as an argument. The method
will then work on that local data with one difference: the `set_name` passed to a block will be set to `nil`.

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

The evaluated block can make use of the following arguments that are passed to it:

* `attribute_value` [Object] - current attribute value that should be altered
* `attribute_name` [String] - a name of currently processed attribute
* `set_object` [Object] - currently processed set that attribute belongs to
* `set_name` [Symbol] - a name of the processed attribute set
* `args` [Array] - an optional arguments passed to the method

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
      for_attributes_that(:should_be_lolized, :process_blank, "lol") do |attribute_value, attribute_name, set_object, set_name, *args|
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

You can pass a set object (`AttributeSet` instance) instead of set name as an argument. The method
will then work on that local data with one difference: the `set_name` passed to a block will be set to `nil`.

Instead of `filter_attrs_from_set` you may also use one of the aliases:

  * `attribute_call_for_set`, `call_attrs_from_set`,       
    `for_attributes_which`, `for_attributes_that`, `for_attributes_that_are`, `for_attributes_which_are`

#### `attributes_to_filter(set,...)` ####

The [`attributes_to_filter`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attributes_to_filter)
method is used for **getting the attributes that should be filtered**.
This is a core method used by other filtering methods to establish a collection of attributes
to be processed but you can use it on your own. It returns an `AttributeSet` instance containing
attribute names that match the given criteria (by default: that are in a set of the given name,
that are present and that have changed lately).

The method takes one manatory argument (`set`) and two optional arguments (`process_all` and `no_presence_check`)
that can be `true` or `false` (default). The `set` may be an object which is kind of String, Symbol (in that case it should contain the name of a set) or it can be an object which is a kind of `AttributeSet` (in that case it should contain a proper object). The first optional argument (`process_all`), when set to `true`, forces method to return also the attributes that haven't changed lately.

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
the presence of any processed attribute as 'a real' attribute. There are three ways
to overcome that problem.

#### Unconditional filtering ####

The first way is to pass the `:no_presence_check` and `:process_all` flags to the filtering method.
That causes filter to be executed for each attribute from a set without any conditions (no checking
for presence of setter/getter method and no checking for changes).

Be aware that by doing that you take full responsibility for attribute set names added to your set.
If you put a name of nonexistent attribute then you may get ugly error later.

With that approach you can filter virtual attributes that are inaccessible to controllers
and don't show up when model is queried for known attributes. Using it may also cause some filters
to be executed more often than needed, since the changes tracking is disabled (`process_all`).

Example:

```ruby
class User

  # declare a virtual attribute
  attr_accessor :real_name

  # define a set
  attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted, :no_presence_check, :process_all) do |value|
      names = value.split(' ')
      self.first_name = names[0]  # assuming first_name exists in a database
      self.last_name  = names[1]  # assuming last_name exists in a database
    end
  end

end
```

#### Marking as semi-real ####

The second way is to use `treat_attributes_as_real` (or simply `treat_as_real`) clause in your model
(available from version 1.2.0 of Attribute Filters). That approach may be applied to attributes
that aren't (may not or should not be) tracked for changes and aren't (may not or should not be) accessible
(to a controller) nor marked as protected.

There are two main differences from the unconditional filtering. First is that marking attribute
as real causes it to be added to the list of all known attributes that is returned by `all_attributes_set`
(a.k.a `all_attributes`). The second is that nothing ugly will happen if there will be non-existent
attributes in a set when filtering method kicks in. That's because the filtering method doesn't require
`:no_presence_check` flag to pick up such attributes. Attributes that could not be handled are simply ignored.

The `:process_all` flag is also not needed since all virtual attributes marked as real are by default
not checked for changes.

Example:

```ruby
class User

  # declare a virtual attribute
  attr_accessor :real_name

  # mark the attribute as real
  treat_as_real :real_name

  # define a set
  attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]  # assuming first_name exists in a database
      self.last_name  = names[1]  # assuming last_name exists in a database
    end
  end

end
```

Be aware that the virtual attributes declared that way will always be filtered
since there is no way to know whether they have changed or not.
That may lead to strange results under some circumstances, e.g. in case of
cutting some part of a string stored in a virtual attribute by using a filter
registered with `before_save`; if such operation will be performed
more than once then the filtering will be performed more than once too.

The presence of virtual attributes is tested by checking if both, a setter and a getter,
methods exist, unless the `no_presence_check` flag is passed to a filtering method.
If both accessors don't exist then the attribute is not processed.

This approach can be easily used with predefined filters.

#### Marking as trackable ####

Since version 1.4.0 of Attribute Filters the **recommended way of dealing with
virtual attributes** is to make use of changes tracking available in Active Model.
To do that look at your ORM's documentation and see 
[`ActiveModel::Dirty`](http://api.rubyonrails.org/classes/ActiveModel/Dirty.html)
and a method `attribute_will_change` that it contains. Just call that method from within
your setter and you're done.

This approach can be easily used with predefined filters.

Conditions:

* Use `attr_accessible` or `attr_protected` to mark the attribute as known
* Use your own setter for notifying that attribute value has changed or `attr_virtual`

The benefit of that approach is that a filter will never be called redundantly contrary
to previous methods.

Example:

```ruby
class User < ActiveRecord::Base

  # declare a virtual attribute
  attr_reader       :real_name
  attr_accessible   :real_name

  # define a set
  attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes

  # create writer that notifies Active Model about changes
  def real_name=(val)
    attribute_will_change!('real_name') if val != real_name
    @real_name = val
  end

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]  # assuming first_name exists in a database
      self.last_name  = names[1]  # assuming last_name exists in a database
    end
  end

end
```

You can also use built-in DSL keyword **`attr_virtual`** that will create setter and getter
for you:

```ruby
class User < ActiveRecord::Base

  # declare a virtual attribute
  attr_virtual      :real_name
  attr_accessible   :real_name

  # define a set
  attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]
      self.last_name  = names[1]
    end
  end

end
```

#### Marking as trackable and semi-real ####

That's a variant of the recommended way of dealing with virtual attributes. It may be useful
if you don't want to (or cannot) add virtual attributes to access lists using `attr_accessible`
or `attr_protected`.

Example:

```ruby
class User < ActiveRecord::Base

  # declare a virtual attribute
  attr_virtual    :real_name

  # mark the attribute as real
  treat_as_real   :real_name

  # tell the engine that all virtual attributes
  # are tracked for changes and it should pick from changed
  # not from all
  virtual_attributes_are_tracked

  # define a set
  attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]
      self.last_name  = names[1]
    end
  end

end
```

Annotations
-----------

Annotations are portions of data that you can bind to attribute names residing within attribute sets.
What for? To store something that is related to the specific attribute and that should be memorized within
a set and/or its copies (if any). You can annotate each attribute name using key -> value pairs where the key is always a symbol and value is any kind of object you want. Only existing attributes can be annotated and deleting attribute
will remove annotations that are assigned to it.

When you copy a set, create difference or intersection of attribute sets, any existing annotations are also copied.
If the operation creates a sum or joins sets then the annotations are mixed too.

The annotations are used by some of the predefined filters described later to precise operations that have
to be taken (e.g. specifying separator string for attribute joining filter and so on).

### Creating annotations ###

You can create annotations during defining a set or you can add them later with `annotate_attribute_set`.
In case of local sets you can also use a method called `annotate`.

#### When defining sets ####

When using the first method just replace attrbute name with a hash, where attribute name is a key
and annotations are another hash containing keys and values.

Example:

```ruby
  class User
    # Set name:         cool
    # Attribute name:   email
    # Annotation key:   some_key
    # Annotation value: some value

    attributes_that_are cool: { :email => { :some_key => "some value" } }
  end
```

The above will annotate `email` attribute within a set `should_be_something` with `some_key` => "some value" pair.
You can mix annotated attributes with unannotated; just put the last ones in front of an array:

```ruby
  class User
    attributes_that_are cool: [ :some_unannotated, { :email => { :some_key => "some value" } } ]
  end
```

or

```ruby
  class User
    attributes_that_are :cool => [ :some_unannotated, { :email => { :some_key => "some value" } } ]
  end
```

#### After defining sets ####

To create annotations for class-level sets use the [`annotate_attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods.html#annotate_attribute_set-instance_method) method (an its aliases):

* **`annotate_attributes_that_are`**
* **`annotate_attributes_that`**
* **`annotate_attributes_are`** 
* **`annotate_attributes_for`**  
* **`annotate_attributes_set`** 
* **`annotate_properties_that`**   
* **`annotate_attributes`**   

Example:

```ruby
  class User
    attributes_that_are cool: [ :some_unannotated, :email, :username ]
    annotate_attributes_that_are cool: [ :email, :some_key, "some value" ]
    annotate_attributes_that_are :cool => { :username => { :some_key => "some value", :other_k => 'other v' } }
  end
```

Caution: Annotating attributes that aren't present in a set
with `annotate_attribute_set` will raise an error.

#### Annotating local sets ####

* **`annotate`**

Example:

```ruby
  class User
    def some_method
      s = ActiveModel::AttributeSet.new([:first_element, :second_element])
      s.annotate(:first_element, :key, 'value')
    end
  end
```

### Removing annotations ###

To remove annotations locally (from sets that are not directly bound to models) you can use:

* **`delete_annotation(attribute_name, annotation_key)`** - to delete specified annotation key for the given attribute
* **`delete_annotations(attribute_name)`** - to delete all annotations for an attribute of the given name
* **`remove_annotations()`** - to remove all annotations from a set

Be aware that using these method to delete annotations from class-level sets won't work.
That's because you'll always get a copy when querying these sets. However there are methods that
will work in a model:

* **`delete_annotations_from_set(set_name, attribute, *annotation_keys)`** - to delete annotation keys for the given attribute
* **`delete_annotations_from_set(set_name, attribute)`** - to delete all annotation keys for the given attribute
* **`delete_annotations_from_set(set_name => *attributes)`** - to delete all annotation keys for the given attribute
* **`delete_annotations_from_set(set_name => { attribute => keys})`** - to delete specified annotation keys for the given attributes

Example:

```ruby
  class User
    attributes_that_are cool: [ :some_unannotated, :email ]

    # That will work
    delete_annotations_from_set cool: :email
    delete_annotations_from_set cool: [ :email, :key_one ]
    delete_annotation_from_set cool: { :email => [:key_one, :other_key], :name => :some_key }

    # That won't affect the global set called 'cool'
    # since we have its copy here, not the original.
    def some_method
      attributes_that_are(:cool).delete_annotation(:email)
    end

    # That won't affect the global set called 'cool'
    # since we have its copy here, not the original.
    attributes_that_are(:cool).delete_annotation(:email)
  end
```

### Updating annotations ###

Calling `annotate` method again on a set or redefining set at a class-level allows to add annotations
or modify their keys.

Example:

```ruby
  class User
    attributes_that_are :cool => { :email => { :some_key => "some value"  } }
    attributes_that_are cool: { :email => { :other_key => "other_value"   } }
    attributes_that_are cool: { :email => { :some_key  => "another_value" } }
    annotate_attributes_that_are :cool, :email, :some_key => "x"
    delete_annotation_from_set :cool => { :email => :other_key }
  end
  
  # In the result there will be only one annotation key left;
  # :some_key with the value of "x"
```

Caution: Annotating attributes that aren't present in a set
with `annotate_attribute_set` or by using `annotate` method will raise an error.

Be aware that updating annotations directly (using `annotate` method) won't work on sets
defined directly in classes describing models. That's because you'll always get
a copy when querying these sets.

```ruby
  class User
    attributes_that_are :cool => { :email => { :some_key => "some value"  } }
    
    # Calling `some_method` won't work on 'cool' global set.
    def some_method
      attributes_that_are(:cool).delete_annotation(:email, :other_key)
    end
  end
```

## Querying annotations ###

To check if a set has any annotations you can use one of the methods:

* **`has_annotation?`** - checks if a set has any annotations
* **`has_annotations?`** - checks if a set has any annotations
* **`has_annotation?(attribute_name)`** - checks if a set has any annotations for the given attribute 
* **`has_annotation?(attribute_name, *annotation_keys)`** - checks if a set has any annotation key for the given attribute

To read annotations you can use :

* **`annotation(attribute_name)`** - gets a hash of annotations or returns nil
* **`annotation(attribute_name, *keys)`** - gets an array annotation values for the given keys (puts nils if key is missing) or returns nil

Example:

```ruby
  class User
    attributes_that_are cool: [ :some_unannotated, :email => { :x => :y } ]

    def q
      attributes_that_are(:cool).annotation(:email, :x, :z)
    end

    def qq
      attributes_that_are(:cool).annotation(:nope, :x, :z)
    end

    # Calling q will return an array: [:y, nil]
    # Calling qq will return nil since attribute is not present (or not annotated)

  end
```

Predefined filters
------------------

Predefined filters are ready-to-use methods
for filtering attributes. You just have to call them
or register them as [callbacks](http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html).

To use all predefined filters you have to manually
include the [`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
module. That will include **all available filtering methods** into your model.

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  the_attribute name:   [:should_be_downcased, :should_be_titleized ]

  before_validation :downcase_attributes
  before_validation :titleize_attributes
end
```

If you don't want to include portions of code that you'll never use, you can include some filters selectively. To do that include just a submodule containing certain filtering method:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Downcase
  include ActiveModel::AttributeFilters::Common::Titleize

  the_attribute name:   [:should_be_downcased, :should_be_titleized ]

  before_validation :downcase_attributes
  before_validation :titleize_attributes
end
```

As you can see, to use any filter you should include a proper submodule, add attribute
names to a proper set and register a callback. The name of a set
that a filtering method will use is predetermined and follows the
convention that it should correspond to the name of a filter. So the
set used by squeezing filter will be named `should_be_squeezed`.

For example, to squeeze attributes `name` and `email` you can write:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  attributes_that should_be_sqeezed: [:email, :name]
  before_validation :squeeze_attributes
end
```

The filtering methods usually come with class-level DSL methods
that are a simple wrappers calling `the_attribute`. So you can
also write:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  squeeze_attributes :email, :name
  before_validation :squeeze_attributes
end
```

### Calling all at once ###

There is a special method called
[`filter_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters.html#filter_attributes-instance_method) that can be registered as a callback. It will call all possible (known) filtering methods
in a predetermined order.

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  include ActiveModel::AttributeFilters::Common::Capitalize

  squeeze_attributes :email, :name
  capitalize_attributes :name

  before_validation :filter_attributes
end
```

Use this method if you're really lazy.
You can also create your own method like that and call all needed filters there:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  include ActiveModel::AttributeFilters::Common::Capitalize

  squeeze_attributes :email, :name
  capitalize_attributes :name

  before_validation :my_total_filtering_method

  def my_total_filtering_method
    squeeze_attributes
    capitalize_attributes
  end
end
```

But to increase readability you should go with the old-fashion way and register
each filtering callback method separately.

### Data types ###

The common filters are aware and can operate on attributes that
are arrays or hashes. If an array or a hash is detected then
the filtering is made **recursively** for each element (or for each value in case
of a hash) and the produced structure is returned. If the attribute has an
unknown type then its value is not altered at all and left intact.

Some of the common filters may treat arrays and hashes in a slight different
way (e.g. joining and splitting filters do that).

The common filters are aware of multibyte strings so string
operations should handle diacritics properly.

### List of filters ###

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
for detailed descriptions.

#### Capitalization ####

* Submodule: [`Capitalize`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Capitalize.html)

##### `capitalize_attributes` #####

Capitalizes attributes.

* Callback method: `capitalize_attributes`
* Class-level helper: `capitalize_attributes(*attribute_names)`
* Uses set: `:should_be_capitalized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

##### `fully_capitalize_attributes` #####

Capitalizes attributes and squeezes spaces that separate strings.

* Callback method: `fully_capitalize_attributes`
* Class-level helper: `fully_capitalize_attributes(*attribute_names)`
* Uses set: `:should_be_fully_capitalized` and `:should_be_titleized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

##### `titleize_attributes` #####

Titleizes attributes.

* Callback method: `titleize_attributes`
* Class-level helper: `titleize_attributes(*attribute_names)`
* Uses set: `:should_be_titleized`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

#### Case ####

* Submodule: [`Case`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Case.html)

##### `upcase_attributes` #####

Upcases attributes.

* Callback method: `upcase_attributes`
* Class-level helper: `upcase_attributes(*attribute_names)`
* Uses set: `:should_be_upcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

##### `downcase_attributes` #####

Downcases attributes.

* Callback method: `downcase_attributes`
* Class-level helper: `downcase_attributes(*attribute_names)`
* Uses set: `:should_be_downcased`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

#### Strip ####

* Submodule: [`Strip`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Strip.html)

##### `strip_attributes` #####

Strips attributes of leading and trailing spaces.

* Callback method: `strip_attributes`
* Class-level helper: `strip_attributes(*attribute_names)`
* Uses set: `:should_be_stripped`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

#### Squeeze ####

* Submodule: [`Squeeze`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Squeeze.html)

##### `squeeze_attributes` #####

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

Result:

> `Some    Name`

will become:

> `Some Name`

##### `squish_attributes` #####

Squishes attributes (removes all whitespace characters on both ends of the string, and then changes remaining consecutive whitespace groups into one space each).

* Callback method: `squish_attributes`
* Class-level helper: `squish_attributes(*attribute_names)`
* Uses set: `:should_be_squished`
* Operates on: strings, arrays of strings, hashes of strings (as values)
* Uses annotations: no

#### Split ####

* Submodule: [`Split`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Split.html)

##### `split_attributes` #####

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
  #          (the nice thing is that it allows to validate the results, not the unsplitted data)
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

#### Join ####

* Submodule: [`Join`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common/Join.html)

##### `join_attributes` #####

Joins attributes and places the results into other attributes or into the same attributes as strings.

* Callback method: `join_attributes`
* Class-level helpers:
 * `join_attributes(attribute_name, parameters_hash)`
 * `join_attributes(attribute_name)`
* Uses set: `:should_be_joined`
* Operates on: strings, arrays of strings
* Uses annotations: yes
 * `join_separator` - a pattern passed to [`join`](http://www.ruby-doc.org/core/Array.html#method-i-join) method (optional)
 * `join_compact` - compact flag; if true then an array is compacted before it's joined (optional)
 * `join_from` - attribute names used as sources for joins

The join filter uses `join` instance method of `Array` class to produce single string from multiple strings.
These strings may be values of other attributes (source attributes), values of an array stored in an attribute
or mix of it. If the `:compact` (`:join_compact` in case of manually annotating a set) parameter is given
and it's not `false` nor `nil` then results are compacted during processing. That means any slices equals to `nil` are 
removed.

The splitted source is a current attribute if the parameter `:from` (or annotation key `:join_from`) is not given.
If the attribute content is a string



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
    are_attributes_that_are(:required_to_trade).all.present? and
    are_attributes_that_are(:required_to_trade).all.valid?
  end

  def attributes_missing_to_trade
    attributes_that_are(:required_to_trade).list.blank? +
    attributes_that_are(:required_to_trade).list.invalid?
  end
end
```

See also
--------

* [Whole documentation](http://rubydoc.info/gems/attribute-filters/)
* [GEM at RubyGems](https://rubygems.org/gems/attribute-filters)
* [Source code](https://github.com/siefca/attribute-filters/tree)
