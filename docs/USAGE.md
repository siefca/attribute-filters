Usage of Attribute Filters
==========================

Attribute sets
--------------

Attribute set is a set of attribute names and optional annotations.
It's like a hash and internally it is a kind of Hash, but differs in
many places.

Attribute sets have simple function; **they group attribute names**. What can
you do with that? For example you can use it to perform some tasks
on all attribute names that are stored in a set (or their values). You can also
combine sets, intersect, exclusively disjuct them, merge with other data, query them,
iterate through them, and so on.

### Data structures ###

Attribute sets are instances of
[`ActiveModel::AttributeSet`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeSet)
class. You can create and update sets freely and store in them wherever you want.

For your convenience Attribute Filters also provides globally created attribute sets that are bound to your models
(at the class-level). The binding is realized simply by using the hash of all these sets. The attribute sets
assigned to models are stored as
[class instance variable](http://blog.codegram.com/2011/4/understanding-class-instance-variables-in-ruby).

**You should interact with the global sets using dedicated DSL keywords** that are available in your models.
These methods will allow you to read or write some data from/to global attribute sets.

Attribute Filters are using `AttributeSet` instances not just to store internal data
but also to interact with other parts of a program. So whenever there is a method
that returns a set of attributes or even a set of set names, the returned value
will probably be an instance of the `AttributeSet` class.

Note that when sets are returned the convention is that:

  * **attribute names are strings**
  * **set names are symbols**
  * **annotations are hashes** attached to attribute names (strings)
  * **annotation keys are symbols**

Once you create some set that is bound to your model (there is a class method `attribute_set` for it)
you cannot remove elements from it. Moreover, any query returning its contents will always
give you the deep copy. Such a separation is a consequence of the idea that **the model-bound attribute
sets should be a part of the interface**, which shouldn't change at runtime. This approach
enforces the declarative design (which is very concise and clear as you read the code).

### Defining the model-level attribute sets ###

First thing that should be done when using the Attribute Filters
is defining the sets of attributes in models.

You can also create local sets (using `ActiveModel::AttributeSet.new`)
or a local sets with extra syntactic sugar (using `ActiveModel::AttributeSet::Query.new`)
but in real-life scenarios you will use model-bound sets that can be later used
by common filters and by your own methods.
 
#### `attribute_set(set_name => attr_names)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `has_attributes_that`) class method allows to **create or update a set** that will be
tied to a model.

Example:

```ruby
class User < ActiveRecord::Base

  has_attributes_that should_be_stripped:     [ :username, :email, :real_name ]
  has_attributes_that should_be_downcased:    [ :username, :email ]
  has_attributes_that should_be_capitalized:  [ :real_name ]

end
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_set`, `attributes_that_are`, `attributes_that`, `properties_that`,         
    `has_attribute_set`, `has_attribute_that`, `has_attribute_that_is`, `has_attributes`,          
    `has_attributes_set`, `has_attributes_that_are`, `has_attributes_that`, `has_properties_that`

#### `filter_attribute(attr => set_names)` ####

You may prefer the alternative syntax, that **uses attribute names**
as primary arguments, but has exactly the same effect as the `attribute_set`.

The [`filter_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:filter_attribute)
(a.k.a `the_attribute`) class method also lets you create or update a set, just the arguments order is reversed
(attribute name goes first).

Example:

```ruby
class User < ActiveRecord::Base

  its_attribute real_name:  [ :should_be_stripped, :should_be_capitalized ]
  its_attribute username:   [ :should_be_stripped, :should_be_downcased   ]
  its_attribute email:      [ :should_be_stripped, :should_be_downcased   ]

end
```

Instead of `filter_attribute` you may also use one of the aliases:

  * `the_attribute`, `attribute_to_set`, `filtered_attribute`, `filtered_attributes`,
    `filters_attribute`, `filters_attributes`, `its_attribute`, `has_attribute`,
    `has_the_attribute`, `has_filtered_attribute`, `has_filtered_attributes`

#### Mixing the syntaxes ####

You can mix both syntaxes given in the examples before.
You can also use regular arguments instead of hashes to create sets:

```ruby
class User < ActiveRecord::Base

  has_attributes_that :should_be_stripped, :username, :email, :real_name

  its_attribute :real_name, :should_be_capitalized
  its_attribute :username,  :should_be_downcased
  its_attribute :email,     :should_be_downcased

end
```

### Querying sets in models ###

When your "global" attribute sets are defined, you can use couple
of class methods to query them.

#### `attribute_set(set_name)` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_set)
(a.k.a `attributes_that`) class method called with a single argument **returns the attribute set
of the given name**.

It will always return the instance of `AttributeSet` class, even if there is no set registered under
the given name (in that case the resulting set will be empty). To know if the returned set is a stub
(placed instead of the missing one) you can use `frozen?` on it or you can call the DSL method
`attribute_set_exists?(set_name)` before querying the global sets for a model.

Example:

```ruby
  User.attributes_that(:should_be_stripped) - User.attributes_that(:should_be_downcased)
  # => #<ActiveModel::AttributeSet: {"real_name"}>
```

Note that the returned set will be a copy of the original set stored within your model.

Alternative syntax:

```ruby
  User.attributes_that.should_be_stripped - User.attributes_that.should_be_downcased
  # => #<ActiveModel::AttributeSet: {"real_name"}>
```

Instead of `attribute_set` you may also use one of the aliases:

  * `attributes_set`, `attributes_that_are`, `attributes_that`, `properties_that`,         
    `has_attribute_set`, `has_attribute_that`, `has_attribute_that_is`, `has_attributes`,          
    `has_attributes_set`, `has_attributes_that_are`, `has_attributes_that`, `has_properties_that`

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/ClassMethods:attribute_sets)
class method returns a MetaSet kind of value containing **all the defined attribute sets** indexed by their names.

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
(a.k.a `attributes_that`) class method called without any arguments is a DSL wrapper that calls `attribute_set(set_name)`
with `set_name` taken from next method call.

Example:

```ruby
  User.attributes_that.should_be_downcased
  # => #<ActiveModel::AttributeSet: {"username", "email"}>
```

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
class method returns a MetaSet kind of value containing **all filtered attributes and sets that the attributes
belong to**. The meta set is indexed by attribute names.

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
a returns a MetaSet kind of value containing **all filtered attributes and sets that the attributes
belong to**.

### Querying sets in model objects ###

It is possible to access attribute sets from within the ActiveModel (or ORM, like ActiveRecord) objects.
To do that you may use instance methods that are designed for that purpose.

#### `attribute_set` ####

The [`attribute_set`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_set)
instance method called withount an argument **returns the attribute set object containing all attributes known
in a current model**.

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

  * `attributes_set`, `attributes_that_are`, `attributes_that`, `properties_that`,         
    `has_attribute_set`, `has_attribute_that`, `has_attribute_that_is`, `has_attributes`,          
    `has_attributes_set`, `has_attributes_that_are`, `has_attributes_that`, `has_properties_that`
    
Instead of `attribute_set` you may also use:

  * `attribute_set_simple(set_name)`

It works same way as `attribute_set(set_name)` but doesn't wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

#### `attribute_sets` ####

The [`attribute_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attribute_sets)
method returns a meta set containing **all the defined attribute sets** indexed by their names.
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
If you'll try to get the value of an element that doesn't exist **the empty, frozen set will be returned**.

Instead of `attribute_sets` you may also use one of the aliases:

  * `attributes_sets`, `properties_sets`

#### `all_attributes` ####

The [`all_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_attributes)
method **returns the attribute set containing all known attributes**. It combines many other sets,
including the sets containing attributes marked as semi-real and virtual (explained later)
and temporary sets obtained by calling various Rails methods. It just tries to collect as many
known attribute names as possible.

Example:

```ruby
  User.first.all_attributes
  # =>  #<ActiveModel::AttributeSet: {"id", "username", "email", "password", "language", "created_at", "updated_at"}>
```

Be aware that this method requires that the used ORM has `attributes` method available for a model object.

Instead of `all_attributes` you may also use the alias:

  * `all_attributes_set`

or call the instance method `attribute_set` without arguments.

The `all_attributes` synopsis is really:

  * `all_attributes(simple = false, no_presence_check = true)`

First argument (`simple`) causes the method to not wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

Second argument (`no_presence_check`) causes the method to not
check if each attribute exists by verifying presence of its accessor
in case of semi-real attributes set that is merged into the resulting set.

#### `all_accessible_attributes` ####

The [`all_accessible_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_accessible_attributes)
method **returns the attribute set containing all accessible attributes**.

Example:

```ruby
  User.first.all_accessible_attributes
  # =>  #<ActiveModel::AttributeSet: {"username", "email", "language"}> 
```
Be aware that this method requires that the used ORM has `accessible_attributes` method available for a model
class. This method works only if your Rails application supoorts accessible attributes (versions up to 3 support it).

Instead of `all_accessible_attributes` you may also use the alias:

  * `accessible_attributes_set`
  
Instead of `all_accessible_attributes` you may also use:

  * `all_accessible_attributes(true)`

It works the same way but doesn't wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

#### `all_inaccessible_attributes` ####

The [`all_inaccessible_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_inaccessible_attributes)
method **returns the attribute set containing all inaccessible attributes**.

Example:

```ruby
  User.first.all_inaccessible_attributes
  # =>  #<ActiveModel::AttributeSet: {"id", "confirmation_token", "encrypted_password", "deleted_at"}> 
```

Be aware that this method requires that the used ORM has `accessible_attributes` and `protected_attributes`
method available in a model. This method works only if your Rails application supoorts accessible
attributes (versions up to 3 support it).

Instead of `all_inaccessible_attributes` you may also use the alias:

  * `inaccessible_attributes_set`
  
Instead of `all_inaccessible_attributes` you may also use:

  * `all_inaccessible_attributes(true)`

It works the same way but doesn't wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

The `all_inaccessible_attributes` synopsis is really:

  * `all_inaccessible_attributes(simple = false, no_presence_check = true)`

First argument (`simple`) causes the method to not wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

Second argument (`no_presence_check`) causes the method to not
check if each attribute exists by verifying presence of its accessor
in case of semi-real attributes set that is used to compute the resulting set.

#### `all_protected_attributes` ####

The [`all_protected_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_protected_attributes)
method **returns the attribute set containing all protected attributes**.

Example:

```ruby
  User.first.all_protected_attributes
  # =>  #<ActiveModel::AttributeSet: {"id", "type"}> 
```

Be aware that this method requires that the used ORM has `protected_attributes` method available for a model
class. This method works only if your Rails application supoorts accessible attributes (versions up to 3 support it).

Instead of `all_protected_attributes` you may also use the alias:

  * `protected_attributes_set`

Instead of `all_protected_attributes` you may also use:

  * `all_protected_attributes(true)`

It works the same way but doesn't wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

#### `all_semi_real_attributes` ####

The [`all_semi_real_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_semi_real_attributes)
method **returns the attribute set containing all attributes marked as semi-real**. This is the concept
of Attribute Filters used to handle attributes that aren't stored in a database (a.k.a virtual attributes, explained later).

Example:

```ruby
  class User
    treats_as_real :trololo
  end
  User.first.all_semi_real_attributes
  # =>  #<ActiveModel::AttributeSet: {"trololo"}> 
```

Instead of `all_semi_real_attributes` you may also use one of the aliases:

  * `semi_real_attributes_set`
  * `treat_as_real` (without arguments)

The `all_semi_real_attributes` synopsis is really:

  * `all_semi_real_attributes(simple = false, no_presence_check = true)`

First argument (`simple`) causes the method to not wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

Second argument (`no_presence_check`) causes the method to not
check if each attribute exists in order to include its name into set.


#### `all_virtual_attributes` ####

The [`all_virtual_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:all_virtual_attributes)
method **returns the attribute set containing all virtual attributes**.

Example:

```ruby
  class User
    attr_virtual :lol
  end
  User.first.all_virtual_attributes
  # =>  #<ActiveModel::AttributeSet: {"lol"}> 
```

Instead of `all_virtual_attributes` you may also use the alias:

  * `virtual_attributes_set`

Instead of `all_virtual_attributes` you may also use:

  * `all_virtual_attributes(true)`

It works the same way but doesn't wrap the result in a transparent proxy
object that brings some syntactic sugar (explained later).

#### `filtered_attribute(attribute_name)` ####

The [`filtered_attribute`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:filtered_attribute)
(a.k.a `the_attribute`) method called with a single argument is used for checking
**what are the sets that the attribute belongs to**. It won't return the exact set object but a duplicate.
It will always return AttributeSet object, even if there is no attribute of the given name
(in that case the resulting set will be empty and frozen).

If the attribute name is not given or it's +nil+ then the name of an attribute is taken from the
name of a next method in the chain call.

Example:

```ruby
 User.first.the_attribute :real_name
 # => #<ActiveModel::AttributeSet: {:should_be_stripped, :should_be_capitalized }>
```

Instead of `filtered_attribute` you may also use one of the aliases:

  * `the_attribute`, `is_the_attribute`, `are_attributes`,     
    `are_the_attributes`

#### `filtered_attribute_simple(attribute_name)` ####

The `filtered_attribute_simple` method is a version of ``filtered_attribute` method that doesn't wrap the resulting
object in a proxy object. The attribute name must be given.

#### `attributes_to_sets` ####

The [`attributes_to_sets`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters:attributes_to_sets)
method returns a meta set containing **all filtered attributes and sets that the attributes belong to**.
The meta set is indexed by attribute names.

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

You can also use one of the aliases:

  * `invalid?`, `is_not_valid?`, `any_invalid?`, `are_not_valid?`, `not_valid?`, `is_any_invalid?`
  * `valid?`, `is_valid?`, `are_valid?`, `all_valid?`, `are_all_valid?`

#### `changed?` and `unchanged?` ####

The `changed?` and `unchanged?` helpers allow you to test if **any** attribute listed in the set
has changed its value (`changed?`) or if **all** attributes from a set remain unchanged (`unchanged?`).


```ruby
  u = User.first
  u.username = ' '
  # => " " 
  
  u.all_attributes.any_changed?
  # => true 
  
  u.all_attributes.unchanged?
  # => false
```

You can also use one of the aliases:

  * `changed?`, `any_changed?`, `have_changed?`, `have_any_changed?`, `is_any_changed?`, `has_any_changed?`, `has_changed?`
  * `unchanged?`, `none_changed?`, `nothing_changed?`, `is_unchanged?`, `are_all_unchanged?`, `all_unchanged?`, 
    `havent_changed?`, `arent_changed?`, `are_not_changed?`, `none_changed?`, `not_changed?`

#### `values` ####

This method simply returns the values of all attributes in a set as an array.

#### `to_set` ####

This method simply produces an object that is a kind of Set and contains all attribute names.

### `AttributeSet` enumerators ###

The `AttributeSet` class is derived from `Hash` class. The keys are attributes,
the values are usually `true` (`TrueClass`) or hashes (`Hash`) if there are any annotations attached
to attribute name. All overriden enumerators are kind of `AttributeSet::Enumerator`.

Let's see what are the differences from standard enumerators that can be found in the Hash class.

  * `each` – works on keys and values (behaves like `each_pair`) but usable with just one argument in a block (key)
  * `each_pair` – iterates throught key => value pairs
  * `each_name_value(active_model_object, no_presence_check = false)` – iterates throught key => attribute value pairs
  * `collect` (`map`) – produces array containg keys that may be altered by the given block
  * `select` – selects new hash with elements for which the given block evaluates to +true+ (yields: keys, values)
  * `select_accessible(active_model_object)` – same as `select` but picks the attributes which have accessors
  * `reject` – reversed `select`
  * `sort` – sorts AttributeSet object by keys
  * `sort_by` – sorts AttributeSet object using the comparison method from a block

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

##### Set & attribute names as methods #####

It's possible to enter a set name or an attribute name as a name
of next method in a call chain instead of passing them as a symbolic argument.
It works with DSL instance methods `attribute_set(set_name)`
and `filtered_attribute(attribute_name)`.

Examples:

```ruby
  User.first.attributes_that.should_be_stripped   # same as User.first.attributes_that(:should_be_stripped)
  User.first.attributes_that_are.required_to_use_app.present?
  User.first.attributes_that.should_be_stripped.sort.list.present?
  
  User.first.the_attribute.username               # same as User.first.the_attribute(:username)
  User.first.the_attribute.username.list.sets
  User.first.the_attribute.username.valid?
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
  attributes_that(:should_be_stripped).all? { |attribute| attribute.METHOD(ARGUMENTS) }
```

Another example, but with `any`:

```ruby
  User.first.attributes_that(:should_be_stripped).any.present?
  # => true
```

You also do:

```ruby
  User.first.attributes_that(:should_be_stripped).any.changed?
  # => false
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
  
  User.first.attributes_that(:should_be_stripped).is.any.valid?
  # => true
  
  User.first.are_attributes_that(:should_be_stripped).all.valid?
  # => true
```

Be aware that calling these methods causes model object to be validated. The required condition
to use these methods is the ORM that has `errors` hash (Active Record has it).

##### Changes tracking helpers #####

* **`changed?`**
* **`unchanged?`**

Syntactic sugar for changes tracking is used when calls to these methods
are combined with selectors described above (presence selectors and elements selectors).

Examples:

```ruby
  u = User.first
  u.username = " "
  
  u.attributes_that(:should_be_stripped).all.changed?
  # => false
  
  u.attributes_that(:should_be_stripped).any.changed?
  # => true
  
  u.attributes_that(:should_be_stripped).list.changed?
  # => #<ActiveModel::AttributeSet: {"username"}>
  
  User.first.all_attributes.is.any.unchanged?
  # => true
  
  User.first.all_attributes.are.none.unchanged?
  # => false
```

Be aware that the required condition to use these methods is the ORM that
has `changes` hash (Active Record has it).

##### Calling custom methods #####

It's possible to call any other methods using selectors.
Note that te method next to the given selector will be called **on a value** of each tested attribute.

Examples:

```ruby
  u = User.first
  
  u.attributes_that(:should_be_stripped).all.is_a?(String)
  # => false

  u.attributes_that(:should_be_stripped).any.is_a?(String)
  # => false
  
  u.attributes_that(:should_be_stripped).list.is_a?(String)
  # => #<ActiveModel::AttributeSet: {"username", "email"}>
```


#### Querying attributes ####

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
  # => {:should_be_downcased => true, :should_be_stripped => true}
  
  User.first.the_attribute(:username).list.sets.to_a
  # => [:should_be_downcased, :should_be_stripped]

```

##### Attribute membership querying #####

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

##### Attribute membership testing #####

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

##### Attribute accessibility testing #####

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

Be aware that this method requires that the used ORM has `accessible_attributes` and `protected_attributes` methods
available in a model. This method works only if your Rails application supoorts accessible attributes (versions up to 3 support it).

##### Attribute validity testing #####

* **`valid?`**
* **`invalid?`**
* **`is_valid?`**
* **`is_invalid?`**

The methods above allow you to test if certain attribute that changed is valid or invalid.

Examples:

```ruby
  u = User.first
  u.username = ' '
  u.the_attribute(:username).is.valid?
  # => false
  u.the_attribute(:username).is_valid?
  # => false
  u.the_attribute(:username).invalid?
  # => true
```

Be aware that this method requires that the used ORM has `valid?` and `errors` methods that allow to validate
model on demand. Also note that validations will run when using that methods.

##### Attribute change testing #####

* **`changed?`**
* **`unchanged?`**
* **`is_changed?`**
* **`is_unchanged?`**
* **`has_changed?`**
* **`hasnt_changed?`**
* **`not_changed?`**

The methods above allow you to test if certain attribute changed recently or not.

Examples:

```ruby
  u = User.first
  u.username = ' '
  u.the_attribute(:username).has_changed?
  # => true
  u.the_attribute(:id).unchanged?
  # => true
```

Be aware that this method requires that the used ORM has `changes` method that allows to query a model for
all changed attributes.

##### Attribute virtuality testing #####

* **`semi_real?`**
* **`virtual?`**
* **`is_semi_real?`**
* **`is_virtual?`**

The methods above allow to you to test if certain attribute is virtual or semi-real (explained later).

```ruby
  u = User.first
  u.the_attribute(:id).is.virtual?
  # => false
  u.the_attribute(:id).is.semi_real?
  # => false
```

##### Attribute value querying #####

  * `value`

Using the `value` method you can get the current value of an attribute.

Example:

```ruby
  u = User.first
  u.the_attribute.username.value
  # => "admin"
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

  its_attribute real_name:  [ :should_be_stripped, :should_be_capitalized ]
  its_attribute username:   [ :should_be_stripped, :should_be_downcased   ]
  its_attribute email:      [ :should_be_stripped, :should_be_downcased   ]

  # Registering filtering callback methods

  before_validation :strip_names
  before_validation :downcase_names
  before_validation :capitalize_names

  # Defining filtering methods

  has_filtering_method :downcase_names,   :should_be_downcased
  has_filtering_method :capitalize_names, :should_be_capitalized
  has_filtering_method :strip_names,      :should_be_stripped

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

By default only **existing, changed and non-blank** attributes are processed.
You can change that behavior by adding a flags as the first arguments:

  * `:process_blank` – tells to also process attributes that are blank (empty or `nil`)
  * `:process_all` - tells to process all attributes, not just the ones that has changed
  * `:no_presence_check` – tells not to check for existence of each processed attribute when processing
    all attributes; increases performance but you must care about putting only the existing attributes into sets

The checking mentioned in `:no_presence_check` flag description is done by querying internal Rails hashes
containing known attributes and internal sets containing virtual attributes added by `attr_virtual` or
`treats_as_real` keywords (described later).

Example:

```ruby
  class User
    has_attribute_that should_be_lolized: :username
    before_validation :lolize

    def lolize
      filter_attributes_that(:should_be_lolized, "lol") do |attribute_value, attribute_name, set_object, set_name, *args|
        [attribute_value, set_name.to_s, attribute_name, *args.flatten].join('-')
      end
    end
    filtering_method :lolize, :should_be_lolized
  end

  u = User.new
  u.username = 'john'
  u.valid?
  u.username
  # => "john-should_be_lolized-username-lol"
```

You can pass a set object (`AttributeSet` instance) instead of set name as an argument. The method
will then work on that local data with one difference: the `set_name` passed to a block will be set to `nil`.

If the block is not given then the method returns an enumerator which can be used to query method later
(when the block is present).

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
  * `:include_missing` – includes attributes that does not exist in a resulting iteration (their values are
    always `nil`); has the effect only when `:process_blank` and `:no_presence_check` are present

The checking mentioned in `:no_presence_check` flag description is done by querying internal Rails hashes
containing known attributes and internal sets containing virtual attributes added by `attr_virtual` or
`treats_as_real` keywords (described later).

Example:

```ruby
  class User
    has_attribute_that should_be_lolized: :username
    before_validation :lolize

    def lolize
      for_attributes_that(:should_be_lolized, :process_blank, "lol") do |attribute_value, attribute_name, set_object, set_name, *args|
        attribute_object << '-' << [set_name.to_s, attribute_name, *args.flatten].join('-')
      end
    end
    filtering_method :lolize, :should_be_lolized
  end

  u = User.new
  u.username = 'john'
  u.valid?
  u.username
  # => "john-should_be_lolized-username-lol"
```

You can pass a set object (`AttributeSet` instance) instead of set name as an argument. The method
will then work on that local data with one difference: the `set_name` passed to a block will be set to `nil`.

If the block is not given then the method returns an enumerator which can be used to query method later
(when the block is present).

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
the presence of any processed attribute as 'a real' attribute. There are different ways
to overcome that problem. First two methods described below are recommended.

#### Marking as virtual ####

Since version 1.4.0 of Attribute Filters the **recommended way of dealing with
virtual attributes** is to make use of Active Model's changes tracking.
To do that look at your ORM's documentation and see 
[`ActiveModel::Dirty`](http://api.rubyonrails.org/classes/ActiveModel/Dirty.html)
and a method `attribute_will_change` that it contains. Just call that method from within
your setter and you're done.

This approach can be easily used with predefined filters. The benefit of it,
contrary to other methods, is that a filter will never be called redundantly.

You should use the built-in DSL keyword **`attr_virtual`** that will create
setter and getter for you.

```ruby
class User < ActiveRecord::Base

  # declare a virtual attribute
  attr_virtual :real_name

  # define a set
  has_attributes_that :should_be_splitted => [ :real_name ]

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
  filtering_method :split_attributes, :should_be_splitted

end
```

Note that for Rails version 3 you may need to declare attribute as accessible using `attr_accessible`
if you want controllers to be able to update its value through assignment passed to model.

You may change the setter and getter for vitrtual attribute on you own, but it should be done
somewhere in the code **before** the `attr_virtual` clause. That will allow `attr_virtual`
to wrap you methods and enable tracking of changes for the attribute.

```ruby
class User < ActiveRecord::Base

  # define a set
  has_attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes   # you could also use :filter_attributes here

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]
      self.last_name  = names[1]
    end
  end
  filtering_method :split_attributes, :should_be_splitted

  # own setter
  def real_name=(val)
    # do somehing specific here (or not)
    @real_name = val
  end

  # own getter
  def real_name
    # do somehing specific here (or not)
    @real_name
  end

  attr_virtual :real_name

end
```

#### Unconditional filtering ####

The next way to filter virtual attribute is to pass the `:no_presence_check` and `:process_all` flags
to the filtering method. That causes filter to be executed for each attribute from a set without
any conditions (no checking for presence of setter/getter method and no checking for changes).

Be aware that by doing that you take full responsibility for attribute set names added to your set.
If you put a name of nonexistent attribute then you may get ugly error later.

With that approach you can filter virtual attributes that are inaccessible to controllers
and don't show up when model is queried for known attributes. Using it may also cause some filters
to be executed more often than needed, since the changes tracking is disabled (`process_all`).

Example:

```ruby
class User

  # define a set
  has_attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes   # you could also use :filter_attributes here

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted, :no_presence_check, :process_all) do |value|
      names = value.split(' ')
      self.first_name = names[0]  # assuming first_name exists in a database
      self.last_name  = names[1]  # assuming last_name exists in a database
    end
  end
  filtering_method :split_attributes, :should_be_splitted

end
```

#### Marking as semi-real ####

There is also a way that bases on using `treats_attributes_as_real` (or simply `treats_as_real`) clause in your model
(available from version 1.2.0 of Attribute Filters). That approach may be applied to attributes
that aren't (may not or should not be) tracked for changes and aren't (may not or should not be) accessible
(to a controller) nor marked as protected (if using Rails version <= 3).

There are two main differences from the unconditional filtering. First is that marking attribute
as real causes it to be added to the list of all known attributes that is returned by `all_attributes_set`
(a.k.a `all_attributes`). The second is that nothing ugly will happen if there will be non-existent
attributes in a set when filtering method kicks in. That's because the filtering method doesn't require
`:no_presence_check` flag to pick up such attributes. Attributes that cannot be handled are simply ignored.

The `:process_all` flag is also not needed since all attributes marked as semi-real are by default
not checked for changes.

Example:

```ruby
class User

  # mark the attribute as real
  treats_as_real :real_name

  # define a set
  has_attributes_that :should_be_splitted => [ :real_name ]

  # register a callback method
  before_validation :split_attributes   # you could also use :filter_attributes here

  # create a filtering method
  def split_attributes
    for_attributes_that(:should_be_splitted) do |value|
      names = value.split(' ')
      self.first_name = names[0]  # assuming first_name exists in a database
      self.last_name  = names[1]  # assuming last_name exists in a database
    end
  end
  filtering_method :split_attributes, :should_be_splitted

end
```

Instead of `treat_as_real` you may also use one of its aliases:

  * `attribute_filters_semi_real`, `treat_attribute_as_real`,  `treat_attributes_as_real`,
    `treats_attribute_as_real`, `treats_attributes_as_real`, `treats_as_real`,             

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

    has_attributes_that_are cool: { :email => { :some_key => "some value" } }
  end
```

The above will annotate `email` attribute within a set `should_be_something` with `some_key` => "some value" pair.
You can mix annotated attributes with unannotated; just put the last ones in front of an array:

```ruby
  class User
    has_attributes_that_are cool: [ :some_unannotated, { :email => { :some_key => "some value" } } ]
  end
```

or

```ruby
  class User
    has_attributes_that_are :cool => [ :some_unannotated, { :email => { :some_key => "some value" } } ]
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
* **`annotates_attributes_that_are`**
* **`annotates_attributes_that`**
* **`annotates_attributes_are`** 
* **`annotates_attributes_for`**  
* **`annotates_attributes_set`** 
* **`annotates_properties_that`**   
* **`annotates_attributes`**
* **`attribute_set_annotate`**

Example:

```ruby
  class User
    has_attributes_that_are cool: [ :some_unannotated, :email, :username ]
    annotates_attributes_that_are cool: [ :email, :some_key, "some value" ]
    annotates_attributes_that_are :cool => { :username => { :some_key => "some value", :other_k => 'other v' } }
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

* **`delete_annotation_from_set(set_name, attribute, *annotation_keys)`** - to delete annotation keys for the given attribute
* **`delete_annotation_from_set(set_name, attribute)`** - to delete all annotation keys for the given attribute
* **`delete_annotation_from_set(set_name => *attributes)`** - to delete all annotation keys for the given attribute
* **`delete_annotation_from_set(set_name => { attribute => keys})`** - to delete specified annotation keys for the given attributes

Instead of `delete_annotation_from_set` you may use the aliases:

  * `delete_annotations_from_set`, `delete_annotation_from_set`, `deletes_annotations_from_set`

Example:

```ruby
  class User
    has_attributes_that_are cool: [ :some_unannotated, :email ]

    # That will work
    deletes_annotations_from_set  cool: :email
    deletes_annotations_from_set  cool: [ :email, :key_one ]
    deletes_annotation_from_set   cool: { :email => [:key_one, :other_key], :name => :some_key }

    # That won't affect the global set called 'cool'
    # since we have its copy, not the original.
    def some_method
      attributes_that_are(:cool).delete_annotation(:email)
    end

    # That won't affect the global set called 'cool'
    # since the method returns its copy, not the original.
    attributes_that_are(:cool).delete_annotation(:email)
  end
```

### Updating annotations ###

Calling `annotate` method again on a set or redefining set at the class-level allows to add annotations
or to modify their keys.

Example:

```ruby
  class User
    has_attributes_that_are :cool => { :email => { :some_key => "some value"  } }
    has_attributes_that_are cool: { :email => { :other_key => "other_value"   } }
    has_attributes_that_are cool: { :email => { :some_key  => "another_value" } }
    annotates_attributes_that_are :cool, :email, :some_key => "x"
    deletes_annotation_from_set :cool => { :email => :other_key }
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
    has_attributes_that_are :cool => { :email => { :some_key => "some value"  } }
    
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

* **`annotation(attribute_name)`** - gets a hash of annotations or returns `nil`
* **`annotation(attribute_name, *keys)`** - gets an array annotation values for the given keys (puts `nil`s if key is missing) or returns `nil`

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

To read **all annotations** use `annotations` method called on an attribute set. For instance:

```ruby
  User.first.attributes_that(:should_be_splitted).annotations
  # => {"some_name"=>{:split_into=>[:first_part, :second_part]}}
```

As you can see it returns a hash with attribute names as keys and annotations as values.
If some attribute from a set doesn't have any annotations then it's not included in the results.

Predefined filters
------------------

Predefined filters are ready-to-use methods for filtering attributes. You just have to call them
or register them as [callbacks](http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html).

To use all predefined filters you have to manually
include the [`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
module. That will include **all available filtering methods** into your model.

Predefined filters work by utilizing global attribute sets of predetermined names. For example
a common filter that downcases attributes will use the set called `:should_be_downcased`.

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  its_attribute name:   [:should_be_downcased, :should_be_titleized ]

  before_validation :downcase_attributes
  before_validation :titleize_attributes
end
```

If you don't want to include portions of code that you'll never use in your model classes, you may
want to include some filters selectively. To do that just include a submodule containing needed filtering method:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Downcase
  include ActiveModel::AttributeFilters::Common::Titleize

  its_attribute name:   [:should_be_downcased, :should_be_titleized ]

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
  has_attributes_that should_be_squeezed: [:email, :name]
  before_validation :squeeze_attributes
end
```

### Filtering keywords ###

The filtering methods usually come with class-level DSL methods
that are helpful wrappers. They are simply calling `the_attribute`
method to add some attributes to a proper set for you.

So you can also write:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  squeezes_attributes :email, :name
  before_validation   :squeeze_attributes
end
```

Some of these helpers are doing some extra work to make things syntactically easier
than with using pure sets. Check the list if common filters for more information.

### Calling all filters ###

There is a special method called
[`filter_attributes`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters.html#filter_attributes-instance_method) that can be registered as a callback. It will call all filtering methods which sets (that they're assigned to)
are non-empty. In other words it will run specific filtering method for each global attribute set if the set exists
and contains at least one element. The calling order is the same as the order of adding sets in your model class.

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common::Squeeze
  include ActiveModel::AttributeFilters::Common::Capitalize

  squeezes_attributes   :email, :name
  capitalizes_attribute :name

  before_validation :filter_attributes
end
```

Or even more simpler (but it will include all common filters):

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  squeezes_attributes    :email, :name
  capitalizes_attribute :name

  before_validation :filter_attributes
end
```

The method of using common filters presented in he example above
is the easiest and the most consistent one.

Of course the `filter_attributes` will also work if the sets are
specified explicitly:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  has_attributes_that :should_be_squeezed     =>  [ :email, :name ]
  has_attributes_that :should_be_capitalized  => :name

  before_validation :filter_attributes
end
```

To know which methods are known to `filter_attributes`
use the `filtering_methods` instance method
available in your model. It returns a meta set containing
attributes set names as keys and the methods assigned
to them as values (both are symbols).

Note that the method above returns **all** known
methods marked as filtering methods, including those
that might not be called until a proper set will
be defined. To check what methods will actually be
called (at a given time) use:

```ruby
  (attribute_sets & filtering_methods).values
```

### Custom filtering order ###

Instead of relaying on `filter_attributes` you may create
your own callback method containing invocations of your
filtering methods in the desired order (independent from
the "natural" order, based on adding the sets to model class):

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  has_attributes_that :should_be_squeezed     =>  [ :email, :name ]
  has_attribute_that  :should_be_capitalized  => :name

  before_validation :prepare_attributes

  def prepare_attributes
    capitalize_attributes   # common filter that uses the set called :should_be_capitalized
    squeeze_attributes      # common filter that uses the set called :should_be_squeezed
  end
end
```

Or you can just register multiple callbacks to achieve the same
result.

### Custom filtering methods ###

You can create your own filtering methods and they will be called
among others by `filter_attributes`. You just have to use special
DSL class method called `filtering_method` to mark your method
and assign its name to some global attribute set (not used by
any other filtering method).

Synopsis:

  * `filtering_method(method_name, set_name)`

The global set of the given name will be looked up when callback
method `filter_attributes` will be called and if non-empty then
the registered method will be called (among others).

Example:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  has_attributes_that should_be_happy: [ :username, :real_name ]
  before_validation :filter_attributes

  def happify
    filter_attributes_that(:should_be_happy) do |v, o|
      v + "-happy"
    end
  end
  filtering_method :happify, :should_be_happy
end
```

Of course, you can set your own method as a callback explicitly
instead of using the `filter_attributes`.

### Data types ###

The common filters are aware of different kinds of data and can operate
on attributes that are arrays or hashes. If an array or a hash is detected then
the filtering is made **recursively** for each element (or for each value in case
of a hash) and the produced value is returned. If the attribute has an
unknown type then its value is not altered at all and left intact.

Some of the common filters may treat arrays and hashes in a slight different
way (e.g. joining and splitting filters do that).

The common filters are aware of multibyte strings so string
operations should handle diacritics properly.

### List of filters ###

See the [COMMON-FILTERS](http://rubydoc.info/gems/attribute-filters/file/docs/COMMON-FILTERS.md) for detailed descriptions and usage examples.

See the
[`ActiveModel::AttributeFilters::Common`](http://rubydoc.info/gems/attribute-filters/ActiveModel/AttributeFilters/Common)
for descriptions of common filtering modules.

Custom applications
-------------------

You may want to use attribute sets for custom logic, not just for the filtering
purposes. For example, you may have some set of attributes that all have to
exist for a user to make deals. Then you may have some method that checks if
user is able to trade by testing the presence of attributes from the defined set.

Example:

```ruby
class User < ActiveRecord::Base

  has_attributes_that_are required_to_trade: [ :username, :email, :real_name, :address, :account ]

  def is_able_to_trade?
    are_attributes_that_are.required_to_trade.all.present? and
    are_attributes_that_are.required_to_trade.all.valid?
  end

  def attributes_missing_to_trade
    attributes_that_are.required_to_trade.list.blank? +
    attributes_that_are.required_to_trade.list.invalid?
  end
end
```

See also
--------

* [Whole documentation](http://rubydoc.info/gems/attribute-filters/)
* [GEM at RubyGems](https://rubygems.org/gems/attribute-filters)
* [Source code](https://github.com/siefca/attribute-filters/tree)
