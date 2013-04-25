require 'spec_helper'

describe DownloadableDocument do
  before (:each) do
    @attr = { :name => "Document Name", :url => "www.example.com", :description => "Test Description",
              :doc_type => "Document Type", :active => 1}
  end

  #attr_accessible :name, :url, :description, :doc_type, :active
  #
  #validates :name, :url, :description, :doc_type, :active, :presence => true

  it "should create a new instance with valid attributes" do
    item = DownloadableDocument.create!(@attr)
    item.should be_valid
  end

  it "should have a name" do
    item = DownloadableDocument.new(@attr.merge(:name => ""))
    item.should_not be_valid
  end

  it "should have a url" do
    item = DownloadableDocument.new(@attr.merge(:url => ""))
    item.should_not be_valid
  end

  it "should have a description" do
    item = DownloadableDocument.new(@attr.merge(:description => ""))
    item.should_not be_valid
  end

  it "should have a doc_type" do
    item = DownloadableDocument.new(@attr.merge(:doc_type => ""))
    item.should_not be_valid
  end

  it "should have a not null 'active'" do
    item = DownloadableDocument.new(@attr.merge(:active => ""))
    item.should_not be_valid
  end

end
