Attribute Filters for Rails
===========================

**attribute-filters version `1.2`** (**`Lavender Bunch`**)

* https://rubygems.org/gems/attribute-filters
* https://github.com/siefca/attribute-filters/tree
* pw@gnu.org


Summary
-------

Attribute Filters extension adds couple of DSL keywords
and some syntactic sugar to Rails, thereby allowing you
to express filtering and grouping model attributes
in a concise and clean way.

When?
-----

You may want to try it when your Rails application often modifies
attribute values that changed recently and uses callbacks to do that.

When the number of attributes that are altered in such a way increases,
you can observe the same thing happening with your filtering
methods. That's because each one is tied to some attribute.

To refine that process you may write more generic methods
for altering attributes. They should be designed to handle
common operations and not be tied to certain attributes.

Let's see that in action.

### Before ###

```ruby
class User < ActiveRecord::Base

  before_validation :strip_and_downcase_username
  before_validation :strip_and_downcase_email
  before_validation :strip_and_capitalize_real_name

  def strip_and_downcase_username
    if username.present?
      self.username = self.username.strip.mb_chars.downcase.to_s
    end
  end

  def strip_and_downcase_email
    if email.present?
      self.email.strip!
      self.email.downcase!
    end
  end

  def strip_and_capitalize_real_name
    if real_name.present?
      self.real_name = self.real_name.strip.mb_chars.split(' ').
                        map { |n| n.capitalize }.join(' ')
    end
  end  
end
```
  
The more attributes there is the more messy it becomes.
The filtering code is not reusable since it operates on specific attributes.

### After ###


```ruby
class User < ActiveRecord::Base
  attributes_that should_be_stripped:     [ :username, :email, :real_name ]
  attributes_that should_be_downcased:    [ :username, :email ]
  attributes_that should_be_capitalized:  [ :real_name ]

  before_validation :strip_names
  before_validation :downcase_names
  before_validation :capitalize_names

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

or even shorter:

```ruby
class User < ActiveRecord::Base
  include ActiveModel::AttributeFilters::Common

  attributes_that should_be_stripped:           [ :username, :email, :real_name ]
  attributes_that should_be_downcased:          [ :username, :email ]
  attributes_that should_be_fully_capitalized:  [ :real_name ]

  before_validation :strip_attributes
  before_validation :downcase_attributes
  before_validation :fully_capitalize_attributes
end
```

If you would rather like to group filters by attribute names then
the alternative syntax may be helpful:

```ruby
class User < ActiveRecord::Base
  the_attribute email:        [ :should_be_stripped, :should_be_downcased   ]
  the_attribute username:     [ :should_be_stripped, :should_be_downcased   ]
  the_attribute real_name:    [ :should_be_stripped, :should_be_capitalized ]
end
```

Attributes that should be altered may be simply added
to the attribute sets that you define and then filtered
with generic methods. You can use these methods in all
your models if you wish.

The last action can be performed by putting the filtering methods into
some base class that all your models inherit form or (better) into your own
handy module that is included in all your models. Alternatively you can
use predefined filters from `ActiveModel::AttributeFilters::Common` module.

More examples and usage
-----------------------

You can use it to filter attributes (as presented above) but you can also
use it to express some logic
[on your own](http://rubydoc.info/gems/attribute-filters/file/docs/USAGE.md#Custom_applications).

* See [USAGE](http://rubydoc.info/gems/attribute-filters/file/docs/USAGE.md) for examples and detailed information about the usage.
* See [whole documentation](http://rubydoc.info/gems/attribute-filters/) to browse all documents.

### Sneak peeks ###

```ruby
  @user.attributes_that(:should_be_stripped).all.present?
  # => false
  
  @user.attributes_that(:should_be_stripped).list.present?
  # => #<ActiveModel::AttributeSet: {"username", "email"}>
  
  @user.the_attribute(:username).should_be_stripped?
  # => true
  
  @user.the_attribute(:username).list.sets
  # => #<ActiveModel::AttributeSet: {:should_be_downcased, :should_be_stripped}>
```

How it works?
-------------

It creates a new Active Model submodule called `AttributeFilters`. That module
contains the needed DSL that goes into your models. It also creates `ActiveModel::AttributeSet`
class which is just a new kind of set, a structure for storing attribute names.

Then it forces Rails to include the `ActiveModel::AttributeFilters` in any model that
at any time includes `ActiveModel::AttributeMethods`. The last one is included
quite often; e.g. Active Record and other popular ORM-s use it. (I'm calling that thechnique
"the accompanying module".)

That's why you can make use of attribute filters without explicitly including
the module, as long as your application uses some popular ORM.

However, if something goes wrong or your application is somehow unusual, you can always
include the `AttributeFilters` module manually in any of your models:

```ruby
class ExampleModel
  include ActiveModel::AttributeFilters
end
```

Requirements
------------

* [activemodel](https://rubygems.org/gems/activemodel)
* [rake](https://rubygems.org/gems/rake)
* [rubygems](http://docs.rubygems.org/)
* [bundler](http://gembundler.com/)

Download
--------

### Source code ###

* https://github.com/siefca/attribute-filters/tree
* `git clone git://github.com/siefca/attribute-filters.git`

### Gem ###

* https://rubygems.org/gems/attribute-filters

Installation
------------

```ruby
gem install attribute-filters
```

Specs
-----

You can run RSpec examples both with

* `bundle exec rake spec` or just `bundle exec rake`
* run a test file directly, e.g. `ruby -S rspec spec/attribute-filters_spec.rb -Ispec:lib`

Common rake tasks
-----------------

* `bundle exec rake bundler:gemfile` – regenerate the `Gemfile`
* `bundle exec rake docs` – render the documentation (output in the subdirectory directory `doc`)
* `bundle exec rake gem:spec` – builds static gemspec file (`attribute-filters.gemspec`)
* `bundle exec rake gem` – builds package (output in the subdirectory `pkg`)
* `bundle exec rake test` – performs tests
* `bundle exec rake Manifest.txt` – regenerates the `Manifest.txt` file
* `bundle exec rake ChangeLog` – regenerates the `ChangeLog` file

Credits
-------

* [iConsulting](http://www.iconsulting.pl/) supports Free Software and has contributed to this library by paying for me to eat when I've been coding.
* [MrZYX (Jonne Haß)](https://github.com/MrZYX) contributed by giving me some hints and answering basic questions on IRC – THX!

License
-------

Copyright (c) 2012 by Paweł Wilk.

attribute-filters is copyrighted software owned by Paweł Wilk (pw@gnu.org).
You may redistribute and/or modify this software as long as you
comply with either the terms of the LGPL (see [LGPL-LICENSE](http://rubydoc.info/gems/attribute-filters/file/docs/LGPL-LICENSE)),
or Ruby's license (see [COPYING](http://rubydoc.info/gems/attribute-filters/file/docs/COPYING)).

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE.
