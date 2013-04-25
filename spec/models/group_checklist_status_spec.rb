require 'spec_helper'

describe GroupChecklistStatus do
  before (:each) do
    @attr = { :checklist_item_id => 1, :group_id => 2, :status => "Status", :notes => "Notes"}
  end

  #attr_accessible :checklist_item_id, :group_id, :status, :notes
  #
  #validates :checklist_item_id, :group_id, :status, :presence => true

  it "should create a new instance with valid attributes" do
    item = GroupChecklistStatus.create!(@attr)
    item.should be_valid
  end

  it "should have a checklist_item_id" do
    item = GroupChecklistStatus.new(@attr.merge(:checklist_item_id => ""))
    item.should_not be_valid
  end

  it "should have a group_id" do
    item = GroupChecklistStatus.new(@attr.merge(:group_id => ""))
    item.should_not be_valid
  end

  it "should have a status" do
    item = GroupChecklistStatus.new(@attr.merge(:status => ""))
    item.should_not be_valid
  end



end
