require 'spec_helper'

describe ProjectType do
  before (:each) do
    @attr = { :name => "Name", :project_category_id => 123 }
  end

  #attr_accessible :name, :description, :project_category_id
  #belongs_to :project_category
  #has_many :projects_subtypes
  #validates :name, :project_category_id, :presence => true
  #default_scope :order => 'name'

  it "should create a new instance with valid attributes" do
    item = ProjectType.create!(@attr)
    item.should be_valid
  end

  describe "name tests" do
    it "should not be blank" do
      item = ProjectType.new(@attr.merge(:name => ""))
      item.should_not be_valid
    end
  end

  describe "project_category_id tests" do
    it "should not be blank" do
      item = ProjectType.new(@attr.merge(:project_category_id => ""))
      item.should_not be_valid
    end
  end

end
