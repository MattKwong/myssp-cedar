class Job < ActiveRecord::Base
  attr_accessible :name, :job_type_id

  has_many :program_users
  belongs_to :job_type

end