class Supporter < ActiveRecord::Base
  attr_accessible :address1, :address2, :affiliation, :city, :employer,
                  :first_name, :gender, :last_name, :profession, :state, :zip
end
