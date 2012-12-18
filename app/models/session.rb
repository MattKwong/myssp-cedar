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

  attr_accessible :name, :period_id, :site_id, :payment_schedule_id, :session_type_id, :program_id,
                  :requests, :schedule_max
  scope :by_budget_line_type, lambda { |id| joins(:item).where("budget_item_type_id = ?", id) }
  scope :to_date, lambda { joins(:period).where("start_date <= ?", Date.today) }
  scope :active, lambda { includes(:program).where("programs.active = ?", 't') }
  scope :junior_high, lambda { joins(:session_type).where("session_types.name = ?", 'Summer Junior High') }
  scope :senior_high, lambda { joins(:session_type).where("session_types.name = ?", 'Summer Senior High') }
  scope :by_type, lambda { |group_type| where("session_type_id = ?", group_type ) }

  def sh_default
    65
  end

  def jh_default
    50
  end

  def senior_high?
    session_type.senior_high?
  end

  def junior_high?
    session_type.junior_high?
  end
  def rollback_requests
    ScheduledGroup.find_all_by_session_id(id).each do |group|
      Registration.find(group.registration_id).update_attribute(:scheduled, false)
      Payment.find_all_by_scheduled_group_id(35).each {|payment| payment.update_attribute(:scheduled_group_id, nil)}
      group.destroy
      puts "Rollback of group #{group.name} done"
    end
  end

  def schedule_requests(target, max)
    #Finds the optimal set of requests for this session and schedules them.
    #Requests that cannot be scheduled are scheduled in the first on their request list which has room

    groups_to_schedule = optimal_set(target, max)
    puts "Schedule_requests groups to schedule: #{groups_to_schedule}"
    unless groups_to_schedule.nil? || groups_to_schedule.empty?
      groups_to_schedule.each do |group_id|
        puts "group id is: #{group_id}"
        group = Registration.find(group_id[:id])
        puts "Requested total is: #{group.requested_total}"
        if (max - scheduled_total) >= group.requested_total
          ScheduledGroup.schedule(group.id, id, 1)
        end
      end
    end

    #puts "Session is #{self.name}."
    #schedule remaining groups
    remaining_requests = Registration.where('scheduled <> ? AND request1 = ?', 't', id)
    #remaining_requests = Registration.unscheduled.find_all_by_request1(id)
    unless remaining_requests.nil? || remaining_requests.empty?
    remaining_requests.each do |reg|
      #puts reg.id
      if reg.request2.nil?
        puts "Unable to schedule group #{reg.name}: request 2"
      else
        if (max - Session.find(reg.request2).scheduled_total) >= reg.requested_total
          ScheduledGroup.schedule(reg.id, reg.request2, 2)
        else
          if reg.request3.nil?
            puts "Unable to schedule group #{reg.name}: request 3"
          else
            if (max - Session.find(reg.request3).scheduled_total) >= reg.requested_total
              ScheduledGroup.schedule(reg.id, reg.request3, 3)
            else
              if reg.request4.nil?
                puts "Unable to schedule group #{reg.name}: request 4"
              else
                if (max - Session.find(reg.request4).scheduled_total) >= reg.requested_total
                  ScheduledGroup.schedule(reg.id, reg.request4, 4)
                else
                  if reg.request5.nil?
                    puts "Unable to schedule group #{reg.name}: request 5"
                  else
                    if (max - Session.find(reg.request5).scheduled_total) >= reg.requested_total
                      ScheduledGroup.schedule(reg.id, reg.request5, 5)
                    else
                      if reg.request6.nil?
                        puts "Unable to schedule group #{reg.name}: request 6"
                      else
                        if (max - Session.find(reg.request6).scheduled_total) >= reg.requested_total
                          ScheduledGroup.schedule(reg.id, reg.request6, 6)
                        else
                          if reg.request7.nil?
                            puts "Unable to schedule group #{reg.name}: request 7"
                          else
                            if (max - Session.find(reg.request7).scheduled_total) >= reg.requested_total
                              ScheduledGroup.schedule(reg.id, reg.request7, 7)
                            else
                              if reg.request8.nil?
                                puts "Unable to schedule group #{reg.name}: request 8"
                              else
                                if (max - Session.find(reg.request8).scheduled_total) >= reg.requested_total
                                  ScheduledGroup.schedule(reg.id, reg.request8, 8)
                                else
                                  if reg.request9.nil?
                                    puts "Unable to schedule group #{reg.name}: request 9"
                                  else
                                    if (max - Session.find(reg.request9).scheduled_total) >= reg.requested_total
                                      ScheduledGroup.schedule(reg.id, reg.request9, 9)
                                    else
                                      if reg.request10.nil?
                                        puts "Unable to schedule group #{reg.name}: request 10"
                                      else
                                        if (max - Session.find(reg.request10).scheduled_total) >= reg.requested_total
                                          ScheduledGroup.schedule(reg.id, reg.request10, 10)
                                        else
                                          puts "Unable to scheduled group #{reg.name} in 10 tries."
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
    end

  def optimal_set(target, max)
    #Returns the array of ids of registrations from a session that constitute the optimal groups to put in this session
    puts "in optimal_set"
    requests = Registration.where('scheduled <> ? AND request1 = ?', 't', id).map {|a| { :id => a.id, :requested => a.requested_total } }
    #requests = Registration.current_unscheduled.find_all_by_request1(id).map {|a| a.id}
    puts "In optimal set requests: #{requests}"
    if requests.length > 0
      combos = create_combo_set(requests)
      puts "Combos is #{combos}"
      session_sets = create_session_sets(combos)
      optimal = find_optimal(session_sets, target - scheduled_total, max - scheduled_total)
      #puts "In optimal set: #{session_sets[optimal][:combo]}"
      return session_sets[optimal][:combo]
    end
  end

  def create_combo_set(requests)
    #accepts an array of n hashes, each containing a session id
    #returns an array of arrays of all possible combinations of those ids
    combos = Array.new
    puts "Start of routine: #{requests}"
    if requests.length <= 1
      combos << [requests.first]
    else
      #puts "In else clause: #{requests}"
      count = requests.length
      subset_requests = requests.first(count - 1)
      combos = create_combo_set(subset_requests)
      #puts "Return from recursive call: #{combos}"
      #add the latest element - requests[count - 1] - to each of the elements in session_sets
      new_sets = combos.clone
      new_sets.each do |set|
        new_set = set + [requests.last]
        #puts "new_set is: #{new_set}"
        combos << new_set
      end
      combos << [requests.last]
      #puts "New combos is: #{combos}"
    end
    #puts "After else clause: #{combos.count}"
    return combos
  end

  def create_session_sets(combos)
    #Accepts the array of combo arrays. Converts each element in array to a hash containing the original array
    #plus the total of requests for that session. Returns the new array of hashes
    puts "Create session combos: #{combos}"
    session_sets = Array.new
    combos.each do |item|
      session_sets << {:combo => item, :total => find_total(item)}
    end
    #puts session_sets
    session_sets
  end

  def find_total(list_of_requests)
    total = 0
    list_of_requests.each { |req| total += req[:requested]}
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
    #puts "Find optimal best set: #{best_set}"
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
      sessions = Session.junior_high.active.with_availability
    else
      sessions = Session.senior_high.active
    end

    sessions.each {|s| sites.push(s.site) }

    #logger.debug sites.uniq
    sites.uniq

  end

  def self.sites_with_avail_for_type(group_type)
    sites = Array.new

    if SessionType.find(group_type).name == "Summer Junior High"
      sessions = Session.junior_high.active
    else
      sessions = Session.senior_high.active
    end
    sessions.each do |session|

      if session.available > 0
        sites.push(session.site)
      end
    end

    sites.uniq
  end

  def available
    default_max = self.junior_high? ? self.jh_default : self.sh_default
    session_max = self.schedule_max.nil? ? default_max : self.schedule_max
    session_available = session_max - self.scheduled_total
    if session_available < 2
      session_available = 0
    end
    session_available
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
  def self.sites_with_avail_for_type_senior
    group_type = SessionType.find_by_name("Summer Senior High").id
    self.sites_with_avail_for_type(group_type)
  end

  def short_name
    site.abbr + " " + period.name.first + period.name.last
  end

  def self.session_matrices(program_type, sh_maximum = 65, jh_maximum = 50)
    #Returns a matrix of session availability, organized in rows and columns with row labels and column headers.
    #Matrix type is Registration, Scheduled or Availability
    #Assumes summer domestic. Sites are the rows; weeks are the columns
    sum_dom = program_type == "summer_domestic" ? true : false
    @site_names = Site.order(:listing_priority).find_all_by_active_and_summer_domestic(true, sum_dom).map { |s| s.name}
    period_names = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, sum_dom).map { |p| p.name}
    period_sh_dates = Period.order(:start_date).find_all_by_active_and_summer_domestic(true, sum_dom).map do |p|
        "#{p.start_date.strftime("%b %-d")} - #{p.start_date.month == p.end_date.month ? p.end_date.strftime(" %-d") : p.end_date.strftime("%b %-d")}"
    end

    #Assign a ordinal value to each row and column
      @site_ordinal = Array.new
      for i in 0..@site_names.size - 1 do
        @site_ordinal[i] = @site_names[i]
      end

      @period_ordinal = Array.new
      for i in 0..period_names.size - 1 do
        @period_ordinal[i] = period_names[i]
      end

    #Create and populate matrices.
      @registration_matrix = Array.new(@site_names.size + 1){ Array.new(period_names.size + 1, 0)}
      @scheduled_matrix = Array.new(@site_names.size + 1){ Array.new(period_names.size + 1, 0)}
      @session_id_matrix = Array.new(@site_names.size + 1){ Array.new(period_names.size + 1, 0)}
      @avail_matrix = Array.new(@site_names.size + 1){ Array.new(period_names.size + 1, 0)}
      @senior_high = Array.new(@site_names.size + 1){ Array.new(period_names.size + 1, true)}

      sum_dom ? registrations = Registration.summer_domestic.unscheduled.current : Registration.other.unscheduled.current

      if registrations
        registrations.each do |r|
          @session = Session.find(r.request1)
          @site = Site.find(@session.site_id)
          @period = Period.find(@session.period_id)
          @row_position = @site_ordinal.index(@site.name)
          @column_position = @period_ordinal.index(@period.name)
          @session_id_matrix[@row_position][@column_position] = @session.id
          @registration_matrix[@row_position][@column_position] += r.requested_counselors + r.requested_youth
        end
      end

      sum_dom ? scheduled_groups = ScheduledGroup.summer_domestic.active_program : ScheduledGroup.other.active_program

      if scheduled_groups
        scheduled_groups .each do |r|
          @session = Session.find(r.session_id)
          @site = Site.find(@session.site_id)
          @period = Period.find(@session.period_id)
          @row_position = @site_ordinal.index(@site.name)
          @column_position = @period_ordinal.index(@period.name)
          @session_id_matrix[@row_position][@column_position] = @session.id
          @scheduled_matrix[@row_position][@column_position] += r.current_total
          #unless (@column_position.nil? || @row_position.nil?)
          #end
        end
      end

    #Populate the availability_matrix by traversing the scheduled_matrix
      for i in 0..@site_names.size - 1 do
        for j in 0..period_names.size - 1 do
          if @session_id_matrix[i][j] > 0
            session = Session.find(@session_id_matrix[i][j])
            @avail_matrix[i][j] = session.available
            if @avail_matrix[i][j] < 0
              @avail_matrix[i][j] = 0
            end
            if session.junior_high?
              @senior_high[i][j] = false
            end
          end
        end
      end

    #Total the rows and columns
      @reg_total = 0
      @sched_total = 0
      for i in 0..@site_names.size - 1 do
        for j in 0..period_names.size - 1 do
          @reg_total += @registration_matrix[i][j]
          @sched_total += @scheduled_matrix[i][j]
        end
        @registration_matrix[i][period_names.size] = @reg_total
        @scheduled_matrix[i][period_names.size] = @sched_total
        @reg_total = @sched_total = 0
      end

      for j in 0 ..period_names.size do
        for i in 0..@site_names.size - 1 do
          @reg_total = @reg_total + @registration_matrix[i][j]
          @sched_total = @sched_total + @scheduled_matrix[i][j]
        end
        @registration_matrix[@site_names.size][j] = @reg_total
        @scheduled_matrix[@site_names.size][j] = @sched_total
        @reg_total = @sched_total = 0
      end

    #Grand totals
      @reg_total = @sched_total = 0
      for i in 0..@site_names.size - 1 do
        @reg_total = @reg_total + @registration_matrix[i][period_names.size]
        @sched_total = @sched_total + @scheduled_matrix[i][period_names.size]
      end
      @registration_matrix[@site_names.size][period_names.size] = @reg_total
      @scheduled_matrix[@site_names.size][period_names.size] = @sched_total

      period_names << "Total"
      @site_names << "Total"

    #Replace zeros in cells which do not represent an active session
      if sum_dom
        for i in 0..@site_names.size - 2 do
          site = Site.active.summer_domestic.find_by_name(@site_names[i]).id
          for j in 0..period_names.size - 2 do
            period = Period.active.summer_domestic.find_by_name(period_names[j]).id
            if Session.where('site_id = ? AND period_id = ?', site, period).size == 0
              @registration_matrix[i][j] = "-"
              @scheduled_matrix[i][j] = "-"
              @avail_matrix[i][j] = "-"
            end
          end
        end
      end

    #Return matrices
      @matrices = { :site_count => @site_names.size - 1, :period_count => period_names.size - 1,
                    :site_names => @site_names, :period_names => period_names,
                    :registration_matrix => @registration_matrix, :scheduled_matrix => @scheduled_matrix,
                    :session_id_matrix => @session_id_matrix, :program_type => program_type,
                    :avail_matrix => @avail_matrix, :senior_high => @senior_high, :period_sh_dates => period_sh_dates,
                    }
  end
end
