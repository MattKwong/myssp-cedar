# == Schema Information
#
# Table name: scheduled_groups
#
#  id                   :integer          not null, primary key
#  current_youth        :integer
#  current_counselors   :integer
#  current_total        :integer
#  session_id           :integer
#  church_id            :integer
#  history              :integer
#  created_at           :datetime
#  updated_at           :datetime
#  name                 :string(255)
#  comments             :text
#  registration_id      :integer
#  scheduled_priority   :integer
#  liaison_id           :integer
#  roster_id            :integer
#  group_type_id        :integer
#  second_payment_total :integer
#  second_payment_date  :date
#

class ScheduledGroup < ActiveRecord::Base

  attr_accessible :name, :comments, :current_counselors, :current_youth,
                  :current_total, :liaison_id, :scheduled_priority,
                  :session_id, :church_id, :registration_id, :group_type_id, :second_payment_date,
                  :second_payment_total

  default_scope :include => :church, :order => 'churches.name'
  scope :active, where('current_total > ?', 0)
  scope :active_program, joins(:session => :program).where(:programs => {:active => 't'})
  scope :not_active_program, where('scheduled_groups.created_at < ?', '2012-09-01'.to_datetime)
  scope :high_school, where(:group_type_id => 2)
  scope :junior_high, where(:group_type_id => 3)

  has_many :payments
  has_many :change_histories
  has_many :adjustments
  belongs_to :church
  belongs_to :liaison
  belongs_to :session
  belongs_to :session_type, :foreign_key => :group_type_id
  has_one :roster
  has_one :registration

  validates :name, :liaison_id, :session_id, :church_id, :registration_id, :group_type_id, :presence => true
  validates_numericality_of :liaison_id, :session_id, :church_id, :registration_id, :group_type_id,
                            :second_payment_total, :only_integer => true
  validates_numericality_of :scheduled_priority, :greater_than => 0,
                            :less_than_or_equal_to => 10,
                            :only_integer => true
  validates_numericality_of :current_youth, :greater_than_or_equal_to => 0,
                            :only_integer => true
  validates_numericality_of :current_counselors, :greater_than_or_equal_to => 0,
                            :only_integer => true

  def self.schedule(group_id, session_id, choice)
    group = ScheduledGroup.new
    reg = Registration.find(group_id)
    group.current_youth = reg.requested_youth
    group.current_counselors = reg.requested_counselors
    group.current_total = reg.requested_total
    group.session_id = session_id
    group.church_id = reg.church_id
    group.name = reg.name
    group.comments = reg.comments
    group.registration_id = reg.id
    group.scheduled_priority = choice
    group.liaison_id = reg.liaison_id
    group.group_type_id = reg.group_type_id
    group.second_payment_total = 0
    group.save!
    roster = Roster.new(:group_id => group.id, :group_type => group.group_type_id)
    roster.save!
    group.update_attribute(:roster_id, roster.id)
    reg.set_scheduled_flag(true)

  #update payments
    Payment.find_all_by_registration_id(reg.id).each do |payment|
      payment.update_attribute(:scheduled_group_id, group.id)
    end
    puts "Scheduling of #{group.name} in #{group.session.name}, choice #{choice} completed."
    return group
  end

  def send_confirmation_email
    UserMailer.schedule_confirmation(self).deliver
  end

  def move(session_id, choice)
    self.update_attributes(:session_id => session_id, :scheduled_priority => choice)
  end

  def late_payment_penalty
    0.1
  end

  def senior_high?
     session_type.name.include?("Senior High")
  end

  def junior_high?
     session_type.name.include?("Junior High")
  end

  def current_balance
    total_due - fee_amount_paid
  end

  def total_amount_paid  #this needs to be checked out - is it picking up all of the payments and excluding processing charges?
    #Payment.sum(:payment_amount, :conditions => ['registration_id = ?', registration_id]) +
        Payment.sum(:payment_amount, :conditions => ['scheduled_group_id = ?', id])
  end

  def fee_amount_paid  #this needs to be checked out - is it picking up all of the payments and excluding processing charges?
    #Payment.sum(:payment_amount, :conditions => ['registration_id = ?', registration_id]) +
        Payment.fee.sum(:payment_amount, :conditions => ['scheduled_group_id = ?', id])
  end

  def total_due
    deposit_amount + second_pay_amount + final_pay_amount - adjustment_total
  end

  def adjustment_total
    Adjustment.sum(:amount, :conditions => ['group_id = ?', id])
  end

  def deposit_amount #the amount due for deposits
    overall_high_water * session.payment_schedule.deposit
  end

  def deposit_paid #the amount of the deposit_amount that has actually been paid
    if fee_amount_paid >= deposit_amount
      deposit_amount
    else
      deposit_amount - fee_amount_paid
    end
  end

  def deposit_outstanding
    deposit_amount - deposit_paid
  end

  def overall_high_water
    totals = ChangeHistory.find_all_by_group_id(id).map { |i| i.new_total }
    totals << Registration.find(registration_id).requested_total << second_payment_total << current_total
    totals.compact.max
  end

  def second_half_high_water
    if second_payment_date.nil?
      overall_high_water
    else
      totals = ChangeHistory.find_all_by_group_id(id).map { |i| if i.created_at > second_payment_date
                                   i.new_total end }
      totals << second_payment_total << current_total
      totals.compact.max
    end
  end

  def second_pay_amount
    second_half_high_water * session.payment_schedule.second_payment
  end

  def second_late_penalty_amount
    if second_late_penalty_due?
      late_payment_penalty  * second_pay_amount
    else
      0
    end
  end

  def second_pay_paid #the amount of the deposit_amount that has actually been paid
    if deposit_outstanding > 0 #no money left for second or final payments
      0
    else
      puts second_pay_amount.to_i
      puts deposit_amount.to_i
      puts fee_amount_paid.to_i
      if (second_pay_amount + deposit_amount) < fee_amount_paid
        second_pay_amount #second payment fully paid
      else
        second_pay_amount + deposit_amount - fee_amount_paid
      end
    end
  end

  def second_pay_outstanding
    second_pay_amount + second_late_penalty_amount - second_pay_paid
  end


  def final_pay_amount
    current_total * session.payment_schedule.final_payment
  end

  def final_late_penalty_amount
    if final_late_penalty_due?
      late_payment_penalty  * final_pay_amount
    else
      0
    end
  end

    def final_pay_paid #the amount of the deposit_amount that has actually been paid
    if second_pay_outstanding > 0 #no money left for final payments
      0
    else
      deposit_amount + second_pay_amount + final_pay_amount - fee_amount_paid
    end
  end

  def final_pay_outstanding
    final_pay_amount + final_late_penalty_amount - final_pay_paid
  end

  def final_late_penalty_due?
    Date.today > session.payment_schedule.final_payment_late_date ? true : false
  end
  def second_late_penalty_due?
    Date.today > session.payment_schedule.second_payment_late_date ? true : false
  end

  def likely_next_payment
    second_payment_date.nil? ? 'Second' : 'Final'
  end

  def likely_next_pay_amount
    likely_next_payment == 'Second' ? second_pay_outstanding : final_pay_outstanding
  end

end
