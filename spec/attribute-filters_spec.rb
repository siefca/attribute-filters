# encoding: utf-8

require 'spec_helper'

describe ActiveModel::AttributeFilters do

  describe TestModel do
    before do
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

  end

  # do the above with ActiveRecord -- look in heisepath for testing examples
      #it "is able to filter model attributes with Active Record as ORM" do
      #  @tm = TestModelAR.new
      #  @tm.username  = " UPCASEĄĘŚĆ      "
      #  @tm.email     = " Some@EXAMPLE.com   "
      #  @tm.real_name = "       sir    rails "
      #  -> { @tm.save }.should_not raise_error
      #  @tm.username.should   == "upcaseąęść"
      #  @tm.email.should      == "Some@EXAMPLE.com"
      #  @tm.real_name.should  == "Sir Rails"
      #end
      
    
end
