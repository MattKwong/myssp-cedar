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

  validates :name, :description, :presence => true
  validates :name, :uniqueness => true

  scope :senior_high, where(:name => 'Summer Senior High')
  scope :junior_high, where(:name => 'Summer Junior High')

  def junior_high?
    name == "Summer Junior High" ? true : false
  end
  def senior_high?
    name == "Summer Junior High" ? true : false
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

  def report_scheduling_results
    results = Array.new
    results << {:description => 'Unscheduled', :number_groups => Registration.current_unscheduled.count,
                :number_requests => (Registration.current_unscheduled.map &:requested_total).sum }
    results << {:description => 'Scheduled', :number_groups => ScheduledGroup.active.active_program.count,
                :number_requests => (ScheduledGroup.active.active_program.map &:current_total).sum }
    for i in 1..10 do
      results << {:description => "Scheduled in choice ##{i}", :number_groups => ScheduledGroup.active.active_program.find_all_by_scheduled_priority(i).count,
                  :number_requests => (ScheduledGroup.active.active_program.find_all_by_scheduled_priority(i).map &:current_total).sum }
    end

    puts results

  end

  def rollback
    sessions = Session.active.find_all_by_session_type_id(id)
    sessions.each {|session| session.rollback_requests }
  end
end
