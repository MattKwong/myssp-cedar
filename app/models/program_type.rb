# == Schema Information
#
# Table name: program_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  position    :integer
#

class ProgramType < ActiveRecord::Base
  attr_accessible :name, :description, :position

  validates :name, :description, :position, :presence => true
  validates :name, :uniqueness => true

  has_many :programs
  #has_many :sessions, :through => :programs

#  acts_as_list

  default_scope :order => :position

  before_destroy :reassign_programs

  def abbr_name
    (name.split.collect { |i| i[0..1] }).join
  end

  def summer_domestic?
    name == "Summer Domestic"
  end

end
