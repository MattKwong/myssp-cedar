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
  scope :unscheduled, where('scheduled <> ?', 't')
  scope :current_unscheduled, where(:scheduled => 'f').where('created_at > ?', '2012-09-01'.to_datetime)
  scope :senior_high, where('group_type_id = ?', 2)
  scope :junior_high, where('group_type_id = ?', 3)
  scope :senior_high_unscheduled, where('group_type_id = ? AND scheduled <> ?', 2, 't')
  scope :junior_high_unscheduled, where('group_type_id = ? AND scheduled <> ?', 3, 't')
  scope :other, lambda {joins(:session_type).where('session_types.name <> ? AND session_types.name <> ?', "Summer Senior High", "Summer Junior High")}
  scope :summer_domestic, lambda {joins(:session_type).where('session_types.name = ? OR session_types.name = ?', "Summer Senior High", "Summer Junior High")}
  scope :current, where('registrations.created_at > ?', '2012-09-01'.to_datetime)
  scope :not_current, where('created_at < ?', '2012-09-01'.to_datetime)

  attr_accessible :name,:comments, :liaison_id, :request1, :request2, :request3,
                  :request4, :request5, :request6,:request7, :request8, :request9,
                  :request10, :requested_counselors, :requested_youth,
                  :requested_total, :scheduled,  :amount_due, :amount_paid, :payment_method,
                  :payment_notes, :group_type_id, :church_id, :registration_step, :id


   validates :name, :requested_youth, :requested_counselors, :presence => true
   validates_numericality_of :requested_youth, :requested_counselors, :request1,
                             :only_integer => true, :greater_than_or_equal_to  => 1
   validate :request_sequence, :message => "All requests must be made in order."
   validate :check_for_duplicate_choices, :message => "You may not select the same session twice."
   before_validation do
     self.requested_total = self.requested_youth + self.requested_counselors
   end
  # The next four methods are for compatibility with the ScheduleGroup model - to allow code sharing even though
  # the attributes are named differently

  def set_scheduled_flag(value)
    self.scheduled = value
    self.save!
  end

  def session
    Session.find(request1)
  end

  def limit
    session_type.limit
  end

  def type
    self.junior_high? ? "Junior High" : "Senior High"
  end
  def junior_high?
    session.junior_high?
  end

  def senior_high?
    session.senior_high?
  end

  def registration_limit
    junior_high? ? 20 : 30
  end

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
  def self.build_schedule(reg_or_sched, type, sh_default = nil, jh_default = nil)

    @schedule = {}
    if type == "summer_domestic" then
      @site_names = Site.order(:listing_priority).find_all_by_active_and_summer_domestic(true, true).map { |s| s.name}
#      @site_names = Site.order(:listing_priority).find_all.map { |s| s.name}
      @period_names = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, true).map { |p| p.name}
#      @period_names = Period.order(:start_date).find_all.map { |p| p.name}
      @title = @page_title = "Domestic Summer Schedule"
    else
      @site_names = Site.order(:listing_priority).find_all_by_active_and_summer_domestic(true, false).map { |s| s.name}
#      @site_names = Site.order(:listing_priority).find_all.map { |s| s.name}
      @period_names = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, false).map { |p| p.name}
#      @period_names = Period.order(:start_date).find_all.map { |p| p.name}
      @title = @page_title = "Special Program Schedule"
    end

    if reg_or_sched == 'scheduled'
      @title += ': Scheduled'
      @page_title += ': Scheduled'
    else
      @title += ': Unscheduled'
      @page_title += ': Unscheduled'
    end

    @period_ordinal = Array.new
    for i in 0..@period_names.size - 1 do
      @period_ordinal[i] = @period_names[i]
    end

    @site_ordinal = Array.new
    for i in 0..@site_names.size - 1 do
      @site_ordinal[i] = @site_names[i]
    end

    @registration_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}
    @scheduled_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}
    @session_id_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}
    @avail_matrix = Array.new(@site_names.size + 1){ Array.new(@period_names.size + 1, 0)}


    Registration.all(:conditions => "(request1 IS NOT NULL) AND (scheduled = 'f')").each do |r|
      @session = Session.find(r.request1)
      @site = Site.find(@session.site_id)

      @period = Period.find(@session.period_id)
      @row_position = @site_ordinal.index(@site.name)
      @column_position = @period_ordinal.index(@period.name)
      @session_id_matrix[@row_position][@column_position] = @session.id
      @registration_matrix[@row_position][@column_position] += r.requested_counselors + r.requested_youth
      unless (@column_position.nil? || @row_position.nil?)
      end

    end

    ScheduledGroup.active_program.each do |r|
      @session = Session.find(r.session_id)
      @site = Site.find(@session.site_id)
      @period = Period.find(@session.period_id)
      @row_position = @site_ordinal.index(@site.name)
      @column_position = @period_ordinal.index(@period.name)
      @session_id_matrix[@row_position][@column_position] = @session.id
      @scheduled_matrix[@row_position][@column_position] += r.current_total
      unless (@column_position.nil? || @row_position.nil?)
      end
    end

    #Populate the availability_matrix by traversing the scheduled_matrix
    #
    for i in 0..@site_names.size - 1 do
      for j in 0..@period_names.size - 1 do
        if @session_id_matrix[i][j] > 0
          session = Session.find(@session_id_matrix[i][j])
          @avail_matrix[i][j] = session.available
          if @avail_matrix[i][j] < 0
            @avail_matrix[i][j] = 0
          end
        end
      end
    end

#total the rows and columns
    @reg_total = 0
    @sched_total = 0
    for i in 0..@site_names.size - 1 do
      for j in 0..@period_names.size - 1 do
        @reg_total += @registration_matrix[i][j]
        @sched_total += @scheduled_matrix[i][j]
      end
      @registration_matrix[i][@period_names.size] = @reg_total
      @scheduled_matrix[i][@period_names.size] = @sched_total
      @reg_total = @sched_total = 0
    end

    for j in 0 ..@period_names.size do
      for i in 0..@site_names.size - 1 do
        @reg_total = @reg_total + @registration_matrix[i][j]
        @sched_total = @sched_total + @scheduled_matrix[i][j]
      end
      @registration_matrix[@site_names.size][j] = @reg_total
      @scheduled_matrix[@site_names.size][j] = @sched_total
      @reg_total = @sched_total = 0
    end
#Grand total
    @reg_total = @sched_total = 0
    for i in 0..@site_names.size - 1 do
      @reg_total = @reg_total + @registration_matrix[i][@period_names.size]
      @sched_total = @sched_total + @scheduled_matrix[i][@period_names.size]
    end
    @registration_matrix[@site_names.size][@period_names.size] = @reg_total
    @scheduled_matrix[@site_names.size][@period_names.size] = @sched_total

    @period_names << "Total"
    @site_names << "Total"

    #Replace zeros in cells which do not represent an active session
    for i in 0..@site_names.size - 2 do
      site = Site.active.summer_domestic.find_by_name(@site_names[i]).id
      for j in 0..@period_names.size - 2 do
        period = Period.active.summer_domestic.find_by_name(@period_names[j]).id
        if Session.where('site_id = ? AND period_id =  ?', site, period).size == 0
          @registration_matrix[i][j] = "-"
        end
      end
    end

    @schedule = { :site_count => @site_names.size - 1, :period_count => @period_names.size - 1,
                  :site_names => @site_names, :period_names => @period_names,
                  :registration_matrix => @registration_matrix, :scheduled_matrix => @scheduled_matrix,
                  :session_id_matrix => @session_id_matrix, :reg_or_sched => reg_or_sched, :type => type,
                  :avail_matrix => @avail_matrix}
  end

end
