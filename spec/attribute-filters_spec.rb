# encoding: utf-8

require 'spec_helper'

describe ActiveModel::AttributeFilters do

    before do
      @tm = TestModel.new
    end

    describe @tm do

      it "is able to filter model attributes properly" do
        @tm.username  = " UPCASEĄĘŚĆ      "
        @tm.email     = " Some@EXAMPLE.com   "
        @tm.real_name = "       sir    rails "
        -> { @tm.save }.should_not raise_error
        @tm.username.should   == "upcaseąęść"
        @tm.email.should      == "Some@EXAMPLE.com"
        @tm.real_name.should  == "Sir Rails"
      end

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

end
