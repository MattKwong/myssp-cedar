# == Schema Information
#
# Table name: registrations
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  liaison_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  request1             :integer
#  request2             :integer
#  request3             :integer
#  request4             :integer
#  request5             :integer
#  request6             :integer
#  request7             :integer
#  request8             :integer
#  request9             :integer
#  request10            :integer
#  requested_counselors :integer
#  requested_youth      :integer
#  requested_total      :integer
#  scheduled            :boolean
#  comments             :text
#  amount_due           :decimal(, )
#  amount_paid          :decimal(, )
#  payment_method       :string(255)
#  payment_notes        :text
#  group_type_id        :integer
#  church_id            :integer
#  registration_step    :string(255)
#

class Registration < ActiveRecord::Base
  belongs_to :church
  belongs_to :liaison
  has_many :payments
  belongs_to :session_type, :foreign_key => :group_type_id
  accepts_nested_attributes_for :session_type

  scope :scheduled, where(:scheduled => 't')
  scope :unscheduled, where(:scheduled => 'f')
  scope :current_unscheduled, where(:scheduled => 'f').where('created_at > ?', '2012-09-01'.to_datetime)
  scope :high_school_unscheduled, where((:group_type_id == 2) && (:scheduled == 'f'))
  scope :junior_high_unscheduled, where(:group_type_id => 3)
  scope :other_unscheduled, where((:group_type_id == 1) || (:group_type_id == 4))
  scope :current, where('created_at > ?', '2012-09-01'.to_datetime)

  attr_accessible :name,:comments, :liaison_id, :request1, :request2, :request3,
                  :request4, :request5, :request6,:request7, :request8, :request9,
                  :request10, :requested_counselors, :requested_youth,
                  :requested_total, :scheduled,  :amount_due, :amount_paid, :payment_method,
                  :payment_notes, :group_type_id, :church_id, :registration_step, :id


   validates :name, :requested_youth, :requested_counselors, :presence => true
   validates_numericality_of :requested_youth, :requested_counselors,
                             :only_integer => true, :greater_than_or_equal_to  => 1
   validate :request_sequence, :message => "All requests must be made in order."
   validate :check_for_duplicate_choices, :message => "You may not select the same session twice."

 #TODO: Test that the requested totals don't exceed the limit which is currently 30'

  #with_options :if => :step2? do |registration|
  #  registration.validates_presence_of :request1
  #  registration.validates_numericality_of :request1, :only_integer => true, :greater_than_or_equal_to  => 1, :message => "must be valid request"
  #  registration.validate :request_sequence, :message => "All requests must be made in order."
  #  registration.validate :check_for_duplicate_choices, :message => "You may not select the same session twice."
  #end
  #
  #with_options :if => :step3? do |registration|
  #  registration.validates_presence_of :amount_paid, :payment_method
  #  registration.validates_numericality_of :amount_paid, :greater_than_or_equal_to  => 1
  #end
  #
  #private
  #def step1?
  #  registration_step == 'Step 1'
  #end
  #def step2?
  #  registration_step == 'Step 2'
  #end
  #def step3?
  #  registration_step == 'Step 3'
  #end

  def deposits_paid
    ##returns the value of deposit payments for this registration
    Payment.deposits_paid(self.id)
  end

  def deposits_due
    ##returns the value of deposit amount to be charged for this registration
    deposit_per_person = Session.find(self.request1).payment_schedule.deposit
    deposit_per_person * requested_total
  end

  def request_sequence
  #This routine fails if there are any non-requests within the sequence of requests.
  a = [request1, request2, request3, request4, request5, request6, request7,
       request8, request9, request10]

  first_nil = a.index{|i| i.nil?}

    unless first_nil.nil?
      suba = a.slice(first_nil, a.size - first_nil)
      next_non_nil = suba.index{|i| i != nil}
      unless next_non_nil.nil?
        error_item = next_non_nil + first_nil
        no_request_message = "A request is required here."
        case error_item
          when 1
            errors.add(:request1, no_request_message)
          when 2
            errors.add(:request2, no_request_message)
          when 3
            errors.add(:request3, no_request_message)
          when 4
            errors.add(:request4, no_request_message)
          when 5
            errors.add(:request5, no_request_message)
          when 6
            errors.add(:request6, no_request_message)
          when 7
            errors.add(:request7, no_request_message)
          when 8
            errors.add(:request8, no_request_message)
          when 9
            errors.add(:request9, no_request_message)
          when 10
            errors.add(:request10, no_request_message)
        end
      end
    end
  end

  def check_for_duplicate_choices

    a = [request1, request2, request3, request4, request5, request6, request7,
       request8, request9, request10]
    a.map! { |i| if i == 0 then i = nil else i end }    # eliminate cases were zeroes are entered for no choice.
    first_nil = a.index{|i| i.nil?}
    if first_nil.nil?
      first_nil = 9
    end

    violations = Array.new
#  first_nil += 1
    a = a.slice(0, first_nil)
    for i in 1..first_nil - 1 do
      test_value = a.shift
      dup_location = a.index(test_value)
      if dup_location
        violations.push(i + dup_location + 1)
      end
    end

  #if violations is nil, then everything passes.
    if violations.size > 0
      error_item = violations.first
      dup_request_message = "Duplicate requests are not permitted."
      case error_item
        when 1
          errors.add(:request1, dup_request_message )
        when 2
          errors.add(:request2, dup_request_message )
        when 3
          errors.add(:request3, dup_request_message )
        when 4
          errors.add(:request4, dup_request_message )
        when 5
          errors.add(:request5, dup_request_message )
        when 6
          errors.add(:request6, dup_request_message )
        when 7
          errors.add(:request7, dup_request_message )
        when 8
          errors.add(:request8, dup_request_message )
        when 9
          errors.add(:request9, dup_request_message )
        when 10
          errors.add(:request10, dup_request_message )
      end
    end
  end

  #These are added to enable DRYing of code used by ScheduledGroup and Registration
  def current_youth
    requested_youth
  end
  def current_counselors
    requested_counselors
  end
  def current_total
    requested_total
  end
end
