  # == Schema Information
#
# Table name: session_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class SessionType < ActiveRecord::Base

  attr_accessible :name, :description
  has_and_belongs_to_many :sessions

  validates :name, :description, :presence => true
  validates :name, :uniqueness => true

  scope :senior_high, where(:name => 'Senior High')
  scope :junior_high, where(:name => 'Junior High')

  def junior_high?
    name == "Junior High" ? true : false
  end
  def senior_high?
    name == "Senior High" ? true : false
  end

  def weekend?
    name == "Weekend of Service" ? true : false
  end

  def break?
    name == "Winter and Spring Break" ? true : false
  end

  def limit
    self.junior_high? ? 20 : 30
  end

  def schedule_largest_first(target, max)
    #Finds all of the session for this session type.
    #Sorts them by the number of first choice requests
    sessions = Session.active.find_all_by_session_type_id(id, :order => :requests).reverse
    sessions.each do |s|
      puts "Scheduling session #{s.name}"
      s.schedule_requests(target, max)
    end
  end

  def schedule_smallest_first(target, max)
    #Finds all of the session for this session type.
    #Sorts them by the number of first choice requests
    sessions = Session.active.find_all_by_session_type_id(id, :order => :requests)
    sessions.each do |s|
      s.schedule_requests(target, max)
    end
  end

  def update_session_requests
    sessions = Session.find_all_by_session_type_id(id)
    sessions.each do |session|
      requests = (Registration.find_all_by_request1(session.id).map &:requested_total).sum
      session.update_attribute(:requests, requests)
    end
  end

  def send_confirmation_emails
    sessions = Session.active.find_all_by_session_type_id(id)
    number = 0
    sessions.each do |session|
      groups = ScheduledGroup.find_all_by_session_id(session.id)
      groups.each do |group|
        group.send_confirmation_email
        number += 1
      end
    end
    number
  end

  def report_scheduling_results(target = nil)
    results = Array.new
    if self.senior_high?
      results << {:description => 'Unscheduled', :number_groups =>  Registration.where("scheduled <> 't' AND created_at > ? AND group_type_id = 2", '2012-09-01'.to_date).count,
                :number_requests => (Registration.current.senior_high_unscheduled.map &:requested_total).sum }
      results << {:description => 'Scheduled', :number_groups => ScheduledGroup.active_program.where('group_type_id = ?', 2).count,
                :number_requests => (ScheduledGroup.active_program.where('group_type_id = ?', 2).map &:current_total).sum }
      for i in 1..10 do
        results << {:description => "Scheduled in choice ##{i}", :number_groups => ScheduledGroup.active_program.where('scheduled_priority = ? and group_type_id = ?', i, 2).count,
                  :number_requests => (ScheduledGroup.high_school.active_program.where('scheduled_priority = ? and group_type_id = ?', i, 2).map &:current_total).sum }
      end
      unless target.nil?
          over_count = 0
          Session.senior_high.active.each { |g| if g.scheduled_total > target then  over_count += 1 end }
          results << {:description => 'Number session over target', :number_groups => over_count,
                      :number_requests => '' }
      end
    else
      results << {:description => 'Unscheduled', :number_groups => Registration.where("scheduled <> 't' AND created_at > ? AND group_type_id = 3", '2012-09-01'.to_date).count,
                :number_requests => (Registration.where("scheduled <> 't' AND created_at > ? AND group_type_id = 3", '2012-09-01'.to_date).map &:requested_total).sum }
      results << {:description => 'Scheduled', :number_groups => ScheduledGroup.junior_high.active_program.count,
                :number_requests => (ScheduledGroup.junior_high.active_program.map &:current_total).sum }
      for i in 1..10 do
        results << {:description => "Scheduled in choice ##{i}", :number_groups => ScheduledGroup.junior_high.active_program.find_all_by_scheduled_priority(i).count,
                  :number_requests => (ScheduledGroup.junior_high.active_program.find_all_by_scheduled_priority(i).map &:current_total).sum }
      end
      unless target.nil?
        over_count = 0
        Session.junior_high.active.each { |g| if g.scheduled_total > target then  over_count += 1 end }
        results << {:description => 'Number session over target', :number_groups => over_count,
                    :number_requests => '' }
      end
    end
    puts results
    results

  end

  def rollback
    sessions = Session.active.find_all_by_session_type_id(id)
    sessions.each {|session| session.rollback_requests }
  end
end
