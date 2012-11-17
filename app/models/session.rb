    # == Schema Information
#
# Table name: sessions
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  site_id             :integer
#  period_id           :integer
#  session_type_id     :integer
#  created_at          :datetime
#  updated_at          :datetime
#  payment_schedule_id :integer
#  program_id          :integer
#

class Session < ActiveRecord::Base

  belongs_to :site
  belongs_to :period
  belongs_to :session_type
  belongs_to :payment_schedule
  belongs_to :program
  has_many :scheduled_groups
  has_many :registrations
  accepts_nested_attributes_for :scheduled_groups

  default_scope includes(:period).order('periods.start_date ASC')

  attr_accessible :name, :period_id, :site_id, :payment_schedule_id, :session_type_id, :program_id
  scope :by_budget_line_type, lambda { |id| joins(:item).where("budget_item_type_id = ?", id) }
  scope :to_date, lambda { joins(:period).where("start_date <= ?", Date.today) }
  scope :active, lambda { joins(:program).where("programs.active = ?", 't') }
  scope :junior_high, lambda { joins(:session_type).where("session_types.name = ?", 'Summer Junior High') }
  scope :senior_high, lambda { joins(:session_type).where("session_types.name = ?", 'Summer Senior High') }
  scope :by_type, lambda { |group_type| where("session_type_id = ?", group_type ) }

  def rollback_requests
    ScheduledGroup.find_all_by_session_id(id).each do |group|
      Registration.find(group.registration_id).update_attribute(:scheduled, false)
      group.destroy
      puts "Rollback of group #{group.name} done"
    end
  end

  def schedule_requests(target, max)
    #Finds the optimal set of requests for this session and schedules them.
    #Requests that cannot be scheduled are scheduled in the first on their request list which has room
    groups_to_schedule = optimal_set(target, max)
    groups_to_schedule.each do |group_id|
      ScheduledGroup.schedule(group_id, id, 1)
    end

    #schedule remaining groups
    remaining_requests = Registration.unscheduled.find_all_by_request1(id)
    remaining_requests.each do |reg|
      puts reg.id
      if reg.request2.nil?
        puts "Unable to schedule group #{reg.name}: request 2"
      else
        if (max - Session.find(reg.request2).scheduled_total) <= reg.requested_total
          ScheduledGroup.schedule(reg.id, reg.request2, 2)
        else
          if reg.request3.nil?
            puts "Unable to schedule group #{reg.name}: request 3"
          else
            if (max - Session.find(reg.request3).scheduled_total) <= reg.requested_total
              ScheduledGroup.schedule(reg.id, reg.request3, 3)
            else
              if reg.request4.nil?
                puts "Unable to schedule group #{reg.name}: request 4"
              else
                if (max - Session.find(reg.request4).scheduled_total) <= reg.requested_total
                  ScheduledGroup.schedule(reg.id, reg.request4, 4)
                else
                  if reg.request5.nil?
                    puts "Unable to schedule group #{reg.name}: request 5"
                  else
                    if (max - Session.find(reg.request5).scheduled_total) <= reg.requested_total
                      ScheduledGroup.schedule(reg.id, reg.request5, 5)
                    else
                      if reg.request6.nil?
                        puts "Unable to schedule group #{reg.name}: request 6"
                      else
                        if (max - Session.find(reg.request6).scheduled_total) <= reg.requested_total
                          ScheduledGroup.schedule(reg.id, reg.request6, 6)
                        else
                          if reg.request7.nil?
                            puts "Unable to schedule group #{reg.name}: request 7"
                          else
                            if (max - Session.find(reg.request7).scheduled_total) <= reg.requested_total
                              ScheduledGroup.schedule(reg.id, reg.request7, 7)
                            else
                              if reg.request8.nil?
                                puts "Unable to schedule group #{reg.name}: request 8"
                              else
                                if (max - Session.find(reg.request8).scheduled_total) <= reg.requested_total
                                  ScheduledGroup.schedule(reg.id, reg.request8, 8)
                                else
                                  if reg.request9.nil?
                                    puts "Unable to schedule group #{reg.name}: request 9"
                                  else
                                    if (max - Session.find(reg.request9).scheduled_total) <= reg.requested_total
                                      ScheduledGroup.schedule(reg.id, reg.request9, 9)
                                    else
                                      if reg.request10.nil?
                                        puts "Unable to schedule group #{reg.name}: request 10"
                                      else
                                        if (max - Session.find(reg.request10).scheduled_total) <= reg.requested_total
                                          ScheduledGroup.schedule(reg.id, reg.request10, 10)
                                        else
                                          puts "Unable to scheduled group #{reg.name} to 10 tries."
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def optimal_set(target, max)
    #Returns the array of ids of registrations from a session that constitute the optimal groups to put in this session
    puts "in optimal_set"
    requests = Registration.current_unscheduled.find_all_by_request1(id).map {|a| a.id}
    session_sets = create_combo_set(requests)
    optimal = find_optimal(session_sets, target - scheduled_total, max - scheduled_total)
    puts session_sets[optimal][:session_list]
    return session_sets[optimal][:session_list]
  end

  def create_combo_set(requests)
    #accepts an array of n session ids and returns an array of arrays of all possible combinations of those ids
    combos = Array.new
    if requests.length <= 2
      combos << [requests.first] << [requests.second] << [requests.first, requests.second]
      return combos
    else
      count = requests.length
      subset_requests = requests.first(count - 1)
      session_sets = create_combo_set(subset_requests)
      #add the latest element - requests[count - 1] - to each of the elements in session_sets
      new_sets = session_sets
      new_sets.each do |set|
        new_set = set << requests[count - 1]
        session_sets << new_set
      end
      session_sets << [requests[count - 1]]
      return session_sets
    end
  end

  def find_total(list_of_requests)
    total = 0
    list_of_requests.each { |req| total += Registration.find(req).requested_total}
    total
  end

  def find_optimal(request_sets, target, max)
    #This routine accepts an array of hashes containing a total session value.
    #It returns the index of the array element that is closest to target
    #puts target, max
    distance = target
    best_set = -1
    index = 0
    request_sets.each do |set|
      unless set[:total] > max
        if (target - set[:total]) < distance
          best_set = index
          distance = target - set[:total]
          #puts distance, best_set
        end
      end
      index = index + 1
      #puts index, best_set, set[:total], distance
    end
    return best_set
  end

  def session_type_junior_high?
    if session_type.name == 'Summer Junior High'
      true
    else
      false
    end
  end
  def week
    period.name
  end
  def scheduled_adults
    (self.scheduled_groups.map &:current_counselors).sum
  end

  def scheduled_youth
    (self.scheduled_groups.map &:current_youth).sum
  end

  def scheduled_total
    scheduled_adults + scheduled_youth
  end

  def registered_total
    #Returns the number of first choice spots requested by unscheduled groups
    requests = Registration.current_unscheduled.find_all_by_request1(id)
    total = (requests.map &:requested_total).sum
  end

  def session_food_purchased
    #if this session is the first in the program, we need to pick up all purchases made prior to the session as well.
    if id == program.first_session_id
      #purchases = program.purchases.where('date < ?', period.end_date.to_date)
      total = program.purchases.where('date < ? ', period.end_date.to_date).inject(0) { |t, p| t += p.food_item_total }
    else
      #purchases = program.purchases.where('date > ? AND date < ?',
      #                            period.start_date.to_date - 1, period.end_date.to_date + 1)
      total = program.purchases.where('date > ? AND date < ?',
                                  period.start_date.to_date - 1, period.end_date.to_date + 1).inject(0) { |t, p| t += p.food_item_total }
    end

    #budget_type = BudgetItemType.find_by_name("Food").id
    #total = 0
    #purchases.each { |p| p.item_purchases.by_budget_line_type(budget_type).each {|i| total += i.total_price } }
    return total
  end

  def cumulative_food_purchased
    program.purchases.where('date < ? ', period.end_date.to_date).inject(0) { |t, p| t += p.food_item_total }
  end

  def session_food_consumption
    #Find an inventory at the end of the previous session
    #logger.debug "In food consumption calc"

    starting_inventory_value + session_food_purchased - ending_inventory_value

  end

  def starting_inventory_value
    starting_inventory = program.food_inventories.where('date = ? ', period.start_date.to_date - 1).last

    if starting_inventory.nil?
      starting_inventory = program.food_inventories.where('date = ? ', period.start_date.to_date - 2).last
    end

    if starting_inventory.nil?
      starting_inventory = program.food_inventories.where('date = ? ', period.start_date.to_date).last
    end

    if starting_inventory.nil?
      0
    else
      starting_inventory.value_in_inventory
    end
  end
  def ending_inventory_value
    #Find an inventory at the last day of the session
    ending_inventory = program.food_inventories.where('date = ? ', period.end_date.to_date).last
    logger.debug ending_inventory.inspect
    if ending_inventory.nil?
      ending_inventory = program.food_inventories.where('date = ? ', period.end_date.to_date - 1).last
    end
    if ending_inventory.nil?
      ending_inventory = program.food_inventories.where('date = ? ', period.end_date.to_date + 1).last
    end
    if ending_inventory.nil?
      starting_inventory_value
    else
      ending_inventory.value_in_inventory
    end
    #logger.debug ending_inventory.inspect
    #logger.debug ending_inventory_value.to_i.inspect
  end

  def session_start_date
   period.start_date.to_date
  end

  def days
    if session_type_junior_high?
      period.end_date.to_date - (period.start_date.to_date + 2)
    else
      period.end_date.to_date - (period.start_date.to_date + 1)
    end
  end

  def volunteer_days
    days * scheduled_total
  end

  def cost_per_day
    if volunteer_days != 0
      total_cost / volunteer_days
    else
      0
    end
  end

  def total_cost
    (period.start_date.to_date..period.end_date.to_date).inject(0) do |sum, date|
      inventory = program.food_inventories.after(date).order('date ASC').first
      if inventory
        sum + inventory.daily_cost
      else
        sum
      end
    end
  end

  def self.by_session_type_and_site(value, site)
    list_of_sessions = Session.where('site_id = ? and session_type_id = ?', site, value)
    logger.debug list_of_sessions.inspect
    list_of_sessions

  end

  def self.sites_for_group_type(group_type)
    sites = Array.new

    if SessionType.find(group_type).name == "Summer Junior High"
      sessions = Session.junior_high.active
    else
      sessions = Session.senior_high.active
    end

    sessions.each {|s| sites.push(s.site) }

    #logger.debug sites.uniq
    sites.uniq

  end

  def self.alt_sites_for_group_type(group_type, session_selections)
    sites = Array.new

    if SessionType.find(group_type).name == "Summer Junior High"
      sessions = Session.junior_high.active
    else
      sessions = Session.senior_high.active
    end

    logger.debug sessions.inspect
    logger.debug session_selections.inspect

    if session_selections
      sessions.delete_if {|s| session_selections.include?(s.id.to_s)}
    end

    logger.debug sessions.inspect

    sessions.each {|s| sites.push(s.site) }
    logger.debug session_selections.inspect

    #logger.debug sites.uniq
    sites.uniq

  end

  def self.sites_for_group_type_senior
    group_type = SessionType.find_by_name("Summer Senior High").id
    self.sites_for_group_type(group_type)
  end

  def short_name
    site.abbr + " " + period.name.first + period.name.last
  end
end
