class Supporter < ActiveRecord::Base
  attr_accessible :address1, :address2, :affiliation, :city, :employer,
                  :first_name, :gender, :last_name, :profession, :state, :zip
  validates :first_name, :last_name, :address1, :city, :state, :employer,
            :profession, :presence => true
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5 }
  #validates :phone, :length => { :maximum => 20 }

end

