class Supporter < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :phone, :phone_type,
                  :first_name, :gender, :last_name, :state, :zip,
                  :employer, :profession,
                  :church_name, :church_type, :church_denom

  #validates_with Validator::SupporterValidator
  validates :first_name, :last_name, :address1, :city, :state, :phone, :phone_type,
            :gender, :presence => true
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates :zip, :presence => true, :length => { :maximum => 10, :minimum => 5 }
  validates :phone, :length => { :maximum => 20 }
end