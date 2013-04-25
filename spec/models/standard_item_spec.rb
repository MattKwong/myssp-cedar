require 'spec_helper'

describe StandardItem do
  before (:each) do
    @attr = { :item_id => 123, :comments => "A comment", :project_subtype_id => 123}
  end

  #attr_accessible :item_id, :comments, :project_subtype_id
  #belongs_to :project_subtype
  #belongs_to :item
  #default_scope joins(:item).order('items.name')
  #validates :item_id, :presence => true

  it "should create a new instance with valid attributes" do
    item = StandardItem.create!(@attr)
    item.should be_valid
  end

  it "it should have an item id" do
    item = StandardItem.new(@attr.merge(:item_id => ""))
    item.should_not be_valid
  end

end
