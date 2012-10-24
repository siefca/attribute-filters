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
      @tm.save
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
      s.should be_eql( { 'real_name' => { :operation => :first_value }, 'email' => { :operation => :e_value }, 'username' => true } )
      c.should be_eql( { 'real_name' => { :operation => :other_value } } )
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
      dupx.send(:annotations).should be_eql( dupy.send(:annotations) )
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
      r.should be_eql( { 'email' => { :operation => :e_value }, 'username' => true } )
    end
  
    it "should be able to join sets (union)" do
      r = @s + @c
      r.to_a.sort.should == [ "email", "real_name", "username" ]
      r.should be_eql(  { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value }, 'username' => true } )
    end
  
    it "should be able to intersect sets" do
      r = @s & @c
      r.to_a.sort.should == [ "real_name" ]
      r.should be_eql( { 'real_name' => { :operation => :first_value } } )
    end
  
    it "should be able to exclusively disjunct sets" do
      r = @s ^ @c
      r.to_a.sort.should == [ "email", "username" ]
      r.should be_eql( { "email" => {:operation=>:e_value}, "username" => true } )
      sp = @s.dup
      sp.annotate(:username, 'k', 'v')
      r = sp ^ @c
      r.to_a.sort.should == [ "email", "username" ]
      r.should be_eql( { 'email' => { :operation => :e_value }, 'username' => { :k => "v" } } )
    end
  
    it "should be able to delete elements from a set" do
      @s.annotate(:username, :some_key, 'string_val')
      @s.should be_eql( { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value },
                                 'username' => { :some_key => 'string_val' } })
      @s.delete_if { |o| o == 'username' }
      @s.include?('username').should == false
      @s.should be_eql( { 'email' => { :operation => :e_value }, 'real_name' => { :operation => :first_value } })
    end
  
    it "should be able to keep elements in a set using keep_if" do
      @s.keep_if { |o| o == 'email' }
      @s.include?('email').should == true
      @s.should be_eql( { 'email' => { :operation => :e_value } } )
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
        squeeze_attributes :sq_eight, :sq_seven
      end
      @tm.sq_one = @tm.sq_two = @tm.sq_three = @tm.sq_four = @tm.sq_five = @tm.sq_six = @tm.sq_seven = @tm.sq_eight = 'yellow  moon'
      -> { @tm.save }.should_not raise_error
      @tm.sq_one.should == 'yelow mon'
      @tm.sq_two.should == 'yellow  mon'
      @tm.sq_three.should == 'yellow  mon'
      @tm.sq_four.should == 'yellow  mon'
      @tm.sq_five.should == 'yelow mon'
      @tm.sq_six.should == 'yelow  moon'
      @tm.sq_seven.should == 'yelow mon'
      @tm.sq_eight.should == 'yelow mon'
    end

    it "should pick attributes" do
      TestModel.class_eval{before_save :pick_attributes}
      TestModel.class_eval do
        attributes_that :should_be_picked, :p_a
        attributes_that :should_be_picked, :p_b => { :pick_separator => " " }
        pick_attributes :p_c, :p_d
        pick_attributes :p_e => / /
        pick_attributes :p_f => { :separator => " ", :from => 1 }
        pick_attributes :p_g => { :from => 2, :to => 3 }
        pick_attributes :p_h => { :range => 2..3 }
        pick_attributes :p_i => { :step => 2, :from => 2, :separator => " " }
        pick_attributes :p_j => { :step => 2, :tail => 2, :separator => " " }
        pick_attributes :p_k => { :joiner => "x", :separator => " ", :head => 1 }
        pick_attributes :p_l => { :head => 2, :step => 2 }
        pick_attributes :p_m => { :enum => true, :head => 2, :step => 2 }
        pick_attributes :p_n => { :enum => true, :head => 2, :step => 2 }
        pick_attributes :p_o => { :head => 2, :step => 2 }
      end
      @tm.p_a = @tm.p_b = @tm.p_c = @tm.p_d = @tm.p_e = @tm.p_f = @tm.p_g = @tm.p_h = 
      @tm.p_i = @tm.p_j = @tm.p_k = "one two three four five"
      @tm.p_l = @tm.p_m = @tm.p_a.split(" ")
      @tm.p_n = @tm.p_o = { :a => 'one', :b => 'two', :c => 'three', :d => 'four', :e => 'five' }
      -> { @tm.save }.should_not raise_error
      @tm.p_a.should == "one two three four five"
      @tm.p_b.should == "one two three four five"
      @tm.p_c.should == "one two three four five"
      @tm.p_d.should == "one two three four five"
      @tm.p_e.should == "onetwothreefourfive"
      @tm.p_f.should == "two three four five"
      @tm.p_g.should == "e "
      @tm.p_h.should == "e "
      @tm.p_i.should == "three five"
      @tm.p_j.should == "one three"
      @tm.p_k.should == "twoxthreexfourxfive"
      @tm.p_l.should == ["e", "o", "re", "u", "v"]
      @tm.p_m.should == ["three", "five"]
      @tm.p_n.should == { 'c' => 'three', 'e' => 'five' }
      @tm.p_o.should == { 'a' => 'e', 'b' => 'o', 'c' => 're', 'd' => 'u', 'e' => 'v' }
    end

    it "should fill attributes with values" do
      TestModel.class_eval{before_save :fill_attributes}
      TestModel.class_eval do
        attributes_that :should_be_filled, :fill_one
        attributes_that :should_be_filled, :fill_two => { :fill_value => 'dupa' }
        attributes_that :should_be_filled, :fill_three => { :fill_value => 'dupa', :fill_any => true }
        fill_attributes :fill_four => 'dupa'
        fill_attributes :fill_five => { :with => 'dupa', :fill_present => true }
        fill_attributes :fill_six => { :with => 'dupa' }
        fill_attributes :fill_seven => { :with => 'dupa', :always => true }
        fill_attributes :fill_eight => { :with => 'dupa', :enums => true }
        fill_attributes :fill_nine => { :with => 'dupa', :always => true, :enums => true }
        fill_attributes :fill_ten => { :with => 'dupa' }
      end
      @tm.fill_one = ''
      @tm.fill_five = @tm.fill_three = 'something'
      @tm.fill_two = @tm.fill_four = @tm.fill_six = nil
      @tm.fill_seven = @tm.fill_eight = @tm.fill_nine =  @tm.fill_ten = ['1',2,:x,nil,'']
      -> { @tm.save }.should_not raise_error
      @tm.fill_one.should == nil
      @tm.fill_two.should == 'dupa'
      @tm.fill_three.should == 'dupa'
      @tm.fill_four.should == 'dupa'
      @tm.fill_five.should == 'dupa'
      @tm.fill_six.should == 'dupa'
      @tm.fill_seven.should == ['dupa','dupa','dupa','dupa','dupa']
      @tm.fill_eight.should == ['1',2,:x,nil,'']
      @tm.fill_nine.should == 'dupa'
      @tm.fill_ten.should == ['1',2,:x,'dupa','dupa']
    end

    it "should reverse attribute values" do
      TestModel.class_eval{before_save :reverse_attributes}
      TestModel.class_eval do
        attributes_that :should_be_reversed, :reverse_one
        attributes_that :should_be_reversed, :reverse_two => { :reverse_enumerable => true }
        reverse_attributes :reverse_three => { :enums => true }
        reverse_attributes :reverse_four
      end
      @tm.reverse_one = @tm.reverse_two = 'dupa'
      @tm.reverse_three = @tm.reverse_four = ['1',2,:x,'dupa']
      -> { @tm.save }.should_not raise_error
      @tm.reverse_one.should == 'apud'
      @tm.reverse_two.should == 'apud'
      @tm.reverse_three.should == ['dupa',:x,2,'1']
      @tm.reverse_four.should == ['1',2,:x,'apud']
    end

    it "should randomize order of attribute values" do
      TestModel.class_eval{before_save :shuffle_attributes}
      TestModel.class_eval do
        attributes_that :should_be_shuffled, :shuffle_one, :shuffle_two
        shuffle_attributes :shuffle_three => { :enums => true }
        shuffle_attributes :shuffle_four
      end
      @tm.shuffle_one = @tm.shuffle_two = 'dupa'
      @tm.shuffle_three = @tm.shuffle_four = ['1',2,:x,2,'dupadupa']
      -> { @tm.save }.should_not raise_error
      @tm.shuffle_one.split("").sort.should == @tm.shuffle_two.split("").sort
      @tm.shuffle_three.sort{ |a,b| a.to_s <=> b.to_s}.should == ['1',2,:x,2,'dupadupa'].sort{ |a,b| a.to_s <=> b.to_s}
      @tm.shuffle_four.take(3).should == ['1',2,:x]
      @tm.shuffle_four.last.should_not == 'dupadupa'
    end

    it "should convert attributes" do
      TestModel.class_eval{before_save :convert_attributes}
      TestModel.class_eval do
        attributes_that :should_be_strings, :to_strings => { :base => 10 }
        attributes_that :should_be_integers, :to_integers
        convert_to_float    :to_floats
        convert_to_string   :to_strings_two
        convert_to_string   :to_strings_three => 2
        convert_to_string   :to_strings_four => { :base => 2, :default => "7" }
        convert_to_fraction :to_fractions
        convert_to_number   :to_numbers
        convert_to_integer  :to_integers_two => 2
        convert_to_boolean  :to_boolean
      end
      @tm.to_strings = 5
      @tm.to_strings_two = @tm.to_strings_four = 0.5.to_r
      @tm.to_strings_three = 123
      @tm.to_integers = "12"
      @tm.to_integers_two = "10001"
      @tm.to_floats = "12.1234"
      @tm.to_fractions = "1/2"
      @tm.to_numbers = [ "1", 2, "3" ]
      @tm.to_boolean = nil
      @tm.save
      @tm.to_strings.should == "5"
      @tm.to_strings_two.should == "1/2"
      @tm.to_strings_four.should == "7"
      @tm.to_strings_three.should == "1111011"
      @tm.to_integers.should == 12
      @tm.to_floats.should == 12.1234
      @tm.to_fractions.should == "1/2".to_r
      @tm.to_numbers.should == [ 1, 2, 3 ]
      @tm.to_integers_two.should == 17
      @tm.to_boolean.should == false
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

      TestModel.class_eval{split_attribute :real_name => {:limit => 2, :flatten => true}}
      @tm.real_name = ["Paweł", "Wilk Trzy Osiem Dziewiec", "Cztery"]
      -> { @tm.save }.should_not raise_error
      @tm.real_name.should == ["Paweł", "Wilk", "Trzy Osiem Dziewiec", "Cztery"]

      TestModel.class_eval{split_attribute :real_name => {:limit => 2, :flatten => false}}
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
        @tm.save
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
