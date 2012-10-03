# encoding: utf-8

require 'spec_helper'

describe ActiveModel::AttributeFilters do

  describe TestModel do
    before do
      TestModel.attributes_that(:should_be_stripped, :email, :real_name)
      TestModel.attributes_that(:should_be_titleized, :real_name)
      @tm = TestModel.new
    end

    it "should return list of sets attribute belongs to" do
      @tm.the_attribute(:email).should include :should_be_stripped
      @tm.the_attribute('email').should include :should_be_stripped
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

    it "should filter model attributes that are arrays" do
      @tm.username          = [" UPCASEĄĘŚĆ      "]
      @tm.email             = [" Some@EXAMPLE.com   ", "  x "]
      @tm.real_name         = ["       sir    rails ", nil]
      @tm.save
      @tm.username.should   == ["upcaseąęść"]
      @tm.email.should      == ["Some@EXAMPLE.com", "x"]
      @tm.real_name.should  == ["Sir Rails", nil]
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
      c = @tm.attributes_that(:should_be_titleized)
      s.annotate(:real_name, :operation, :first_value)
      s.annotate(:email,     :operation, :e_value)
      c.annotate(:real_name, :operation, :some_value)
      c.annotate(:real_name, :operation, :other_value)
      s.instance_eval{annotations}.should ==  { 'real_name' => { :operation => :first_value }, 'email' => { :operation => :e_value } }
      c.instance_eval{annotations}.should ==  { 'real_name' => { :operation => :other_value } }
      -> {TestModel.class_eval do
        attributes_that should_be_sth: [ :abc, :atr_one => {:ak => "av"}, :atr_two => {:sk => "sv"} ]
        attributes_that should_be_sth: [:atr_three, :atr_two, :yy]
        attributes_that should_be_sth: {:atr_three => {:fak => "fav"}, :atr_two => {:flala => "flala2"}, :fyy => nil}
        annotate_attribute_set should_be_sth: {:atr_three => {:ak => "av"}, :atr_two => {:lala => "lala2"}, :yy => nil}
        annotate_attribute_set should_be_sth: [:atr_three, :oo => "oe"]
        annotate_attribute_set should_be_sth: [:atr_three, :aa, "bb"]
        annotate_attribute_set should_be_sth: [:atr_three, :hh, "hh"]
        annotate_attributes_that :should_be_sth, :atr_three, :six => 6
        annotate_attribute_set :should_be_sth => [:atr_three, :cc, "dd"]
        annotate_attribute_set :should_be_sth => [:atr_three, :ccc, "ddd"]
        delete_annotation_from_set :should_be_sth, :atr_three, :ccc
        delete_annotation_from_set :should_be_sth => { :atr_three => [ :hh ] }
      end}.should_not raise_error
      @tm.attributes_that(:should_be_sth).annotation(:atr_one).should == {:ak => "av"}
      @tm.attributes_that(:should_be_sth).annotation(:atr_two, :lala).should == "lala2"
      @tm.attributes_that(:should_be_sth).annotation(:atr_x, :lalax).should == nil
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :oo).should == "oe"
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :aa).should == "bb"
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :cc).should == "dd"
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :ccc).should == nil
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :six).should == 6
      @tm.attributes_that(:should_be_sth).has_annotations?.should == true
      @tm.attributes_that(:should_be_sth).has_annotation?(:atr_three).should == true
      @tm.attributes_that(:should_be_sth).has_annotation?(:atr_three, :ak).should == true
      @tm.attributes_that(:should_be_sth).has_annotation?(:atr_nope).should == false
      @tm.attributes_that(:should_be_sth).has_annotation?(:atr_three, :nope).should == false
      @tm.attributes_that(:should_be_sth).delete_annotation(:atr_three, :cc)
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :cc).should == "dd"
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :hh).should == nil
      dupx = TestModel.attributes_that(:should_be_sth)
      dupy = @tm.attributes_that(:should_be_sth)
      dupx.send(:annotations).should == dupy.send(:annotations) 
      dupx.object_id.should_not == dupy.object_id
      -> {TestModel.class_eval do
        annotate_attributes_that :should_be_sth => { :atr_three => { :cc => "ee" } }
        annotate_attribute_set should_be_sth: [:atr_three, :oo => "of"]
        attributes_that should_be_sth: { :atr_one => {:ak => "ax"} }
      end}.should_not raise_error
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :cc).should == "ee"
      @tm.attributes_that(:should_be_sth).annotation(:atr_three, :oo).should == "of"
      @tm.attributes_that(:should_be_sth).annotation(:atr_one).should == {:ak => "ax"}
      @tm.attributes_that(:should_be_sth).annotation(:atr_two, :lala).should == "lala2"
    end
  end

  describe "AttributeSet set operations" do
    before do
      TestModel.attributes_that(:should_be_stripped, :email, :real_name)
      TestModel.attributes_that(:should_be_titleized, :real_name)
      @tm = TestModel.new
      @s = @tm.attributes_that(:should_be_stripped)
      @c = @tm.attributes_that(:should_be_titleized)
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
      end
      @tm = TestModel.new
    end

    after do
      TestModel.class_eval{@__attribute_sets = nil}
      @tm.attributes_that(:should_be_splitted).should be_empty
      @tm.attributes_that(:should_be_joined).should be_empty
      @tm.attributes_that(:should_be_splitted).annotation(:real_name).should == nil
      @tm.attributes_that(:should_be_joined).annotation(:real_name).should == nil 
    end

    it "should squeeze attributes" do
      TestModel.class_eval{before_save :squeeze_attributes}
      TestModel.class_eval do
        attributes_that :should_be_squeezed, :sq_one
        attributes_that :should_be_squeezed, :sq_six => { :squeeze_other_str => 'l' }
        squeeze_attributes :sq_two => 'o'
        squeeze_attributes :sq_three => { :with_character => 'o' }, :sq_four => 'o', :sq_five => nil
      end
      @tm.sq_one = @tm.sq_two = @tm.sq_three = @tm.sq_four = @tm.sq_five = @tm.sq_six = 'yellow  moon'
      -> { @tm.save }.should_not raise_error
      @tm.sq_one.should == 'yelow mon'
      @tm.sq_two.should == 'yellow  mon'
      @tm.sq_three.should == 'yellow  mon'
      @tm.sq_four.should == 'yellow  mon'
      @tm.sq_five.should == 'yelow mon'
      @tm.sq_six.should == 'yelow  moon'
    end

    it "should convert attributes" do
      TestModel.class_eval{before_save :convert_attributes}
      TestModel.class_eval do
        attributes_that :should_be_strings, :to_strings => { :base => 10 }
        attributes_that :should_be_integers, :to_integers
        convert_to_float  :to_floats
        convert_to_string :to_strings_two
        convert_to_string :to_strings_three => 2
        convert_to_string :to_strings_four => { :base => 2, :default => "7" }
        convert_to_fraction :to_fractions
        convert_to_number :to_numbers
      end
      @tm.to_strings = 5
      @tm.to_strings_two = @tm.to_strings_four = 0.5.to_r
      @tm.to_strings_three = 123
      @tm.to_integers = "12"
      @tm.to_floats = "12.1234"
      @tm.to_fractions = "1/2"
      @tm.to_numbers = [ "1", 2, "3" ]
      -> { @tm.save }.should_not raise_error
      @tm.to_strings.should == "5"
      @tm.to_strings_two.should == "1/2"
      @tm.to_strings_four.should == "7"
      @tm.to_strings_three.should == "1111011"
      @tm.to_integers.should == 12
      @tm.to_floats.should == 12.1234
      @tm.to_fractions.should == "1/2".to_r
      @tm.to_numbers.should == [ 1, 2, 3 ]
    end

    shared_examples "splitting" do |ev|
      before { TestModel.class_eval{before_save :split_attributes} }
      it "should split attributes using syntax: #{ev}" do
        TestModel.class_eval(ev)
        @tm.real_name = "Paweł Wilk Trzy"
        @tm.first_name = nil
        @tm.last_name = nil
        #-> { @tm.save }.should_not raise_error
        @tm.save
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == 'Wilk'
        @tm.first_name = nil
        @tm.last_name = nil
        @tm.real_name = "Paweł"
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == nil
      end
    end

    shared_examples "splitting_array" do |de, ev, rn|
      before do
        TestModel.class_eval{before_save :split_attributes}
      end
      it "should split array attribute #{de}" do
        TestModel.class_eval(ev)
        @tm.real_name = rn
        @tm.first_name = nil
        @tm.last_name = nil
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == 'Wilk'
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
      include_examples "splitting", "the_attribute :real_name => { :should_be_splitted => { :split_into => [:first_name, :last_name] } }"
      include_examples "splitting", "the_attribute :real_name => [ :should_be_splitted => { :split_into => [:first_name, :last_name] } ]"
      include_examples "splitting", "the_attribute :real_name, [ :should_be_splitted => { :split_into => [:first_name, :last_name] } ]"
    end
    
    context "with no pattern and no limit" do
      include_examples "splitting_array", "", "split_attribute :real_name => { :into => [ :first_name, :last_name ], :flatten => true }",
                                          ["Paweł", "Wilk", "Trzy"]
    end

    context "with a single space pattern and without a limit" do
      include_examples  "splitting_array", "having 3 elements",
                        "split_attribute :real_name => {:pattern => ' ', :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł", "Wilk", "Trzy"]
      include_examples  "splitting_array", "having 2 elements and first containing pattern (space)",
                        "split_attribute :real_name => {:pattern => ' ', :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł Wilk", "Trzy"]
    end

    context "with a single space pattern and with a limit" do
      include_examples  "splitting_array", "having 3 elements",
                        "split_attribute :real_name => {:pattern => ' ', :limit => 2, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł", "Wilk", "Trzy"]
      include_examples  "splitting_array", "having 2 elements and first containing pattern (space)",
                        "split_attribute :real_name => {:pattern => ' ', :limit => 2, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł Wilk", "Trzy"]
      include_examples  "splitting_array", "having 2 elements and first containing pattern (space)",
                        "split_attribute :real_name => {:pattern => ' ', :limit => 10, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł", "Wilk"]
      include_examples  "splitting_array", "having 1 element and first containing pattern (space)",
                        "split_attribute :real_name => {:pattern => ' ', :limit => 2, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł Wilk"]
      it "should split array attribute having 2 elements and second containing pattern (space)" do
        TestModel.class_eval{split_attribute :real_name => {:pattern => ' ', :limit => 2, :into => [ :first_name, :last_name ], :flatten => true}}
        @tm.real_name = ["Paweł", "Wilk Trzy", "Cztery"]
        @tm.first_name = nil
        @tm.last_name = nil
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == 'Wilk'
      end
    end

    context "without a pattern and with a limit" do
      include_examples  "splitting_array", "having 3 elements",
                        "split_attribute :real_name => {:limit => 2, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł", "Wilk", "Trzy"]
      include_examples  "splitting_array", "having 2 elements",
                        "split_attribute :real_name => {:limit => 2, :into => [ :first_name, :last_name ], :flatten => true}",
                        ["Paweł", "Wilk"]
    end

    it "should split array attribute with the destination in the same place" do
      TestModel.class_eval{split_attribute :real_name => { :flatten => true } }
      TestModel.class_eval{before_save :split_attributes}
      @tm.real_name = ["Paweł", "Wilk Trzy", "Cztery"]
      @tm.first_name = nil
      @tm.last_name = nil
      -> { @tm.save }.should_not raise_error
      @tm.first_name.should == nil
      @tm.last_name.should == nil
      @tm.real_name.should == ["Paweł", "Wilk", "Trzy", "Cztery"]

      TestModel.class_eval{split_attribute :real_name => {:limit => 2}}
      @tm.real_name = ["Paweł", "Wilk Trzy Osiem Dziewiec", "Cztery"]
      -> { @tm.save }.should_not raise_error
      @tm.real_name.should == [["Paweł"], ["Wilk", "Trzy Osiem Dziewiec"], ["Cztery"]]

      TestModel.class_eval{split_attribute :real_name => {:limit => 2, :pattern => ' '}}
      @tm.real_name = ["Paweł", "Wilk Trzy", "Cztery"]
      -> { @tm.save }.should_not raise_error
      @tm.real_name.should == [["Paweł"], ["Wilk", "Trzy"], ["Cztery"]]

      TestModel.class_eval{split_attribute :real_name => {:pattern => ' '}}
      @tm.real_name = ["Paweł", "Wilk Trzy", "Cztery"]
      -> { @tm.save }.should_not raise_error
      @tm.real_name.should == [["Paweł"], ["Wilk", "Trzy"], ["Cztery"]]
    end

    shared_examples "joining" do |ev,rn,rns,rnt|
      before do
        TestModel.class_eval do
          before_save :join_attributes
        end
      end
      it "should join attributes using syntax: #{ev}" do
        TestModel.class_eval(ev)
        # source attributes are strings:
        @tm.real_name = rn
        @tm.first_name = "Paweł"
        @tm.last_name = "Wilk"
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == 'Wilk'
        @tm.real_name.should == 'Paweł Wilk'
        # source attributes are strings and nils:
        @tm.first_name = "Paweł"
        @tm.last_name = nil
        @tm.real_name = rns
        @tm.class.annotate_attributes_that(:should_be_joined, :real_name, :join_compact, true)
        -> { @tm.save }.should_not raise_error
        @tm.first_name.should == 'Paweł'
        @tm.last_name.should == nil
        @tm.real_name.should == 'Paweł'
        # source attributes are arrays and strings:
        @tm.first_name = ["Paweł", "Wilk"]
        @tm.last_name = "Trzeci"
        @tm.real_name = rnt
        -> { @tm.save }.should_not raise_error
        @tm.real_name.should == 'Paweł Wilk Trzeci'
        
      end
    end

    context "with join_attributes" do
      include_examples "joining", "join_attributes :real_name", ["Paweł", "Wilk"], ["Paweł"], ["Paweł", "Wilk", "Trzeci"] 
      include_examples "joining", "join_attributes :real_name", ["Paweł Wilk"], ["Paweł"], ["Paweł Wilk", "Trzeci"]
      include_examples "joining", "join_attributes :real_name", "Paweł Wilk", "Paweł", "Paweł Wilk Trzeci"
      include_examples "joining", "join_attributes :real_name => [ :first_name, :last_name ]"
      include_examples "joining", "join_attributes :real_name, [ :first_name, :last_name ]"
      include_examples "joining", "join_attributes :real_name => { :from => [ :first_name, :last_name ] }"
      include_examples "joining", "join_attributes :real_name, :from => [ :first_name, :last_name ]"
      include_examples "joining", "join_attributes [ :first_name, :last_name ] => :real_name"
      include_examples "joining", "join_attributes [ :first_name, :last_name ], :real_name"
      include_examples "joining", "join_attributes [ :first_name, :last_name ] => { :into => :real_name }"
    end

    context "with attributes_that" do
      include_examples "joining", "attributes_that :should_be_joined => { :real_name => { :join_from => [:first_name, :last_name] } }"
      include_examples "joining", "attributes_that :should_be_joined => [ :real_name => { :join_from => [:first_name, :last_name] } ]"
    end

    context "with the_attribute" do
      include_examples "joining", "the_attribute :real_name => { :should_be_joined => { :join_from => [:first_name, :last_name] } }"
      include_examples "joining", "the_attribute :real_name => [ :should_be_joined => { :join_from => [:first_name, :last_name] } ]"
      include_examples "joining", "the_attribute :real_name, [ :should_be_joined => { :join_from => [:first_name, :last_name] } ]"
    end

  end # describe ActiveModel::AttributeFilters::Common

end # describe ActiveModel::AttributeFilters
