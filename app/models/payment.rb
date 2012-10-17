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
  validates_inclusion_of :payment_type, :in => ['Initial', 'Deposit', 'Second', 'Final', 'Other', 'Processing Charge'], :message => "Invalid payment type"

  def self.record_deposit(reg_id, deposit_amount, processing_charge, type, notes)
    p = Payment.create(:payment_date => Date.today, :registration_id => reg_id, :payment_amount => deposit_amount,
          :payment_method => type, :payment_type => 'Deposit', :payment_notes => notes)
    if processing_charge.to_i > 0
      Payment.create(:payment_date => Date.today, :registration_id => reg_id, :payment_amount => processing_charge,
                     :payment_method => type, :payment_type => 'Processing Charge', :payment_notes => notes)
    end
    return p
  end

end
