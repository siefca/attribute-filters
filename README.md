Attribute Filters for Rails
===========================

**attribute-filters version `1.0`** (**`Sugar, ah honey honey`**)

**THIS IS BETA!**

* https://rubygems.org/gems/attribute-filters
* https://github.com/siefca/attribute-filters/tree
* mailto:pw@gnu.org


Summary
-------

Attribute Filters adds couple of DSL keywords and some syntactic sugar
to Rails thereby allowing you to express filtering and groupping
model attributes in a concise and clean way.

When?
-----

If your Rails application often filters the attributes that has changed
recently and uses callbacks to achieve that, then you may consider
refining that process and write methods for handling common operations
not certain attributes. See what I mean below.

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
  attributes_that should_be_capitalized:  [ :username, :email ]
  
  before_validation :strip_names
  before_validation :downcase_names
  before_validation :capitalize_names
  
  def downcase_names
    filter_attributes_that(:should_be_downcased) do |atr|
      atr.mb_chars.downcase.to_s
    end
  end
  
  def capitalize_names
    filter_attributes_that(:should_be_capitalized) do |atr|
      atr.mb_chars.split(' ').map { |n| n.capitalize }.join(' ')
    end
  end
  
  def strip_names
    for_attributes_that(:should_be_stripped) { |atr| atr.strip! }
  end
  
end
```

Attributes that have to be altered in a common ways simply may be added to sets
and then filtered with more generic methods. You can share these methods 
across all your models if you wish to by putting them into some base class
or (better) by including your own handy module to your models.

Usage
-----

You can use it to do attribute filtering as presented above but you can also
try using ActiveModel::AttributeSet directly, which helps to express some logic.
For example:

```ruby
class User < ActiveRecord::Base
  
  attributes_that_are required_to_trade: [ :username, :home_address, :bank_account ]
  
  def can_trade?
    are_attributes(:required_to_trade).all.present?
  end
  
end
```

* See [USAGE](http://rubydoc.info/gems/attribute-filters/file/docs/USAGE) for more examples and detailed information about the usage.
* See [whole documentation](http://rubydoc.info/gems/attribute-filters/) to browse all documents.

How it works?
-------------

It creates a new Active Model module called ActiveModel::AttributeFilters. That module
contains the needed DSL that goes into your models. It also creates ActiveModel::AttributeSet
class which is just a new kind of set, a structure for storing sets of attribute names.

Then it forces Rails to include the AttributeFilters in any model that
at any time will include ActiveModel::AttributeMethods. The last one is included
quite often; e.g. ActiveRecord and other popular ORM-s use it. (I'm calling it
"the accompanying module".)

That's why you can make use of attribute filters without explicitly including
the module, as long as your application relies on any popular ORM.

If something will go wrong however or your application is somehow unusual, you can always
include the AttributeFilters module manually in any of your models:

```
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

```
gem install attribute-filters
```

Specs
-----

You can run RSpec examples both with

* `rake spec` or just `rake`
* run a test file directly, e.g. `ruby -Ilib -Ispec spec/attribute-filters_spec.rb`

Common rake tasks
-----------------

* `bundle exec rake bundler:gemfile` – regenerate the `Gemfile`
* `bundle exec rake docs` – render the documentation (output in the subdirectory directory `doc`)
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
comply with either the terms of the LGPL (see {file:docs/LGPL}),
or Ruby's license (see {file:docs/COPYING}).

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE.
