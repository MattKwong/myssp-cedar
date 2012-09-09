# == Schema Information
#
# Table name: payments
#
#  id                 :integer          not null, primary key
#  registration_id    :integer
#  payment_date       :date
#  payment_amount     :decimal(, )
#  payment_method     :string(255)
#  payment_notes      :text
#  created_at         :datetime
#  updated_at         :datetime
#  scheduled_group_id :integer
#  payment_type       :string(255)
#

class Payment < ActiveRecord::Base

  attr_accessible :id, :registration_id, :payment_date, :payment_amount, :payment_method,
                  :payment_notes, :scheduled_group_id, :payment_type
  belongs_to :registration
  belongs_to :scheduled_group

  validates :payment_date, :payment_amount, :payment_method, :presence => true
  validates_numericality_of :payment_amount
  validates_inclusion_of :payment_type, :in => ['Initial', 'Deposit', 'Second', 'Final', 'Other'], :message => "Invalid payment type"

end
