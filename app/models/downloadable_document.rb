# == Schema Information
#
# Table name: downloadable_documents
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  url         :string(255)
#  description :string(255)
#  active      :boolean
#  created_at  :datetime
#  updated_at  :datetime
#  doc_type    :string(255)
#

class DownloadableDocument < ActiveRecord::Base
  attr_accessible :name, :url, :description, :doc_type, :active

  validates :name, :url, :description, :doc_type, :active, :presence => true
end
