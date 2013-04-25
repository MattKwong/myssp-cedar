require 'spec_helper'

describe ProjectCategory do
  before (:each) do
    @attr = { :name => "Category Name", :description => "A Test Description" }
  end

  #has_many :project_types
  #attr_accessible :name, :description
  #validates :name, :description, :presence => true
  #default_scope :order => 'name'

  it "should create a new instance with valid attributes" do
    item = ProjectCategory.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "should not be blank" do
      item = ProjectCategory.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end
  end

  describe "description tests" do
    it "should not be blank" do
      item = ProjectCategory.new(@attr.merge(:description => ""))
      item.should_not be_valid
    end
  end

end
