# encoding: utf-8

require 'spec_helper'

describe ActiveModel::AttributeFilters do

  describe TestModel do
    before do
      TestModel.attributes_that(:should_be_stripped, :email, :real_name)
      TestModel.attributes_that(:should_be_capitalized, :real_name)
      @tm = TestModel.new
    end

    it "should be able to filter model attributes properly" do
      @tm.username          = " UPCASEĄĘŚĆ      "
      @tm.email             = " Some@EXAMPLE.com   "
      @tm.real_name         = "       sir    rails "
      -> { @tm.save }.should_not raise_error
      @tm.username.should   == "upcaseąęść"
      @tm.email.should      == "Some@EXAMPLE.com"
      @tm.real_name.should  == "Sir Rails"
    end

    it "should not filter model attributes that are blank" do
      @tm.username = nil
      @tm.save
      @tm.username.should == nil
      @tm.username = ""
      @tm.save
      @tm.username.should == ""
    end
    
    it "should not filter model attributes that aren't present" do
      -> { @tm.touch_nonexistent }.should_not raise_error
    end

    it "should not filter model attributes that haven't changed" do
      @tm.test_attribute = "unchanged"
      @tm.add_string
      @tm.save
      @tm.test_attribute.should == 'unchanged_some_string'
      @tm.add_string
      @tm.test_attribute.should == 'unchanged_some_string'
      @tm.test_attribute = 'unchanged'
      @tm.save
      @tm.add_string
      @tm.test_attribute.should == 'unchanged'
    end

    it "should operate on annotations" do
      s = @tm.attributes_that(:should_be_stripped)
      c = @tm.attributes_that(:should_be_capitalized)
      s.annotate(:real_name, :operation, :first_value)
      s.annotate(:email,     :operation, :e_value)
      c.annotate(:real_name, :operation, :some_value)
      c.annotate(:real_name, :operation, :other_value)
      s.instance_eval{annotations}.should ==  { 'real_name' => { :operation => :first_value }, 'email' => { :operation => :e_value } }
      c.instance_eval{annotations}.should ==  { 'real_name' => { :operation => :other_value } }
    end
  end

  describe "AttributeSet set operations" do
    before do
      TestModel.attributes_that(:should_be_stripped, :email, :real_name)
      TestModel.attributes_that(:should_be_capitalized, :real_name)
      @tm = TestModel.new
      @s = @tm.attributes_that(:should_be_stripped)
      @c = @tm.attributes_that(:should_be_capitalized)
      @s.annotate(:real_name, :operation, :first_value)
      @s.annotate(:email,     :operation, :e_value)
      @c.annotate(:real_name, :operation, :some_value)
      @c.annotate(:real_name, :operation, :other_value)
    end
  
    it "should be able to relatively complement sets" do
      r = @s - @c
      r.to_a.sort.should == [ "email", "username" ]
      r.instance_eval{annotations}.should == { 'email' => { :operation => :e_value } }
    end
  
    it "should be able to join sets (union)" do
      r = @s + @c
      r.to_a.sort.should == [ "email", "real_name", "username" ]
      r.instance_eval{annotations}.should == { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value } }
    end
  
    it "should be able to intersect sets" do
      r = @s & @c
      r.to_a.sort.should == [ "real_name" ]
      r.instance_eval{annotations}.should == { 'real_name' => { :operation => :first_value } }
    end
  
    it "should be able to exclusively disjunct sets" do
      r = @s ^ @c
      r.to_a.sort.should == [ "email", "username" ]
      r.instance_eval{annotations}.should == { 'email' => { :operation => :e_value } }
      sp = @s.dup
      sp.annotate(:username, 'k', 'v')
      r = sp ^ @c
      r.to_a.sort.should == [ "email", "username" ]
      r.instance_eval{annotations}.should == { 'email' => { :operation => :e_value }, 'username' => { :k => "v" } }
    end
  
    it "should be able to delete elements from a set" do
      @s.annotate(:username, :some_key, 'string_val')
      @s.instance_eval{annotations}.should == { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value },
                                 'username' => { :some_key => 'string_val' } }
      @s.delete_if { |o| o == 'username' }
      @s.include?('username').should == false
      @s.instance_eval{annotations}.should == { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value } }
    end
  
    it "should be able to keep elements in a set using keep_if" do
      @s.keep_if { |o| o == 'email' }
      @s.include?('email').should == true
      @s.instance_eval{annotations}.should == { 'email' => { :operation => :e_value } }
    end
  end

  describe ActiveModel::AttributeFilters::Common do

    before do
      TestModel.class_eval do
        include ActiveModel::AttributeFilters::Common
        @__attribute_sets = nil
        before_save :split_attributes
      end
      @tm = TestModel.new
    end

    shared_examples "splitting" do |ev|
      it "should split attributes using syntax: #{ev}" do
        TestModel.class_eval(ev)
        @tm.real_name = "Paweł Wilk Trzy"
        @tm.first_name = nil
        @tm.last_name = nil
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == 'Wilk'
        @tm.first_name = nil
        @tm.last_name = nil
        @tm.real_name = "Paweł"
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == nil
        TestModel.class_eval do
          attribute_set(:should_be_splitted).delete_annotations(:real_name)
          @__attribute_sets = nil
        end
        @tm.attributes_that(:should_be_splitted).annotation(:real_name).should == nil
      end
    end

    context "with split_attribute" do
      include_examples "splitting", "split_attribute :real_name => [ :first_name, :last_name ]"
      include_examples "splitting", "split_attribute :real_name, [ :first_name, :last_name ]"
      include_examples "splitting", "split_attribute :real_name => { :into => [ :first_name, :last_name ] }"
      include_examples "splitting", "split_attribute :real_name, :into => [ :first_name, :last_name ]"
    end

    context "with attributes_that" do
      include_examples "splitting", "attributes_that :should_be_splitted => { :real_name => { :split_into => [:first_name, :last_name] } }"
      include_examples "splitting", "attributes_that :should_be_splitted => [ :real_name => { :split_into => [:first_name, :last_name] } ]"
    end

    context "with the_attribute" do
      include_examples "splitting", "the_attribute :real_name, [ :should_be_splitted => { :split_into => [:first_name, :last_name] } ]"
    end

  end

end
