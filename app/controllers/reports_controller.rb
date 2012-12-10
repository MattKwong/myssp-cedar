require 'csv'

class ReportsController < ApplicationController
  load_and_authorize_resource :liaison, :parent => false

  def church_and_liaison(scope = nil)
    @headers = get_headers_full_report
    @rows = get_rows_full_report

    respond_to do |format|
      format.csv { create_csv("liaisons_and_churches-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Liaisons and Churches'}
    end
  end


  def scheduled_liaisons
    @headers = get_headers_scheduled_liaisons
    @rows = get_rows_scheduled_liaisons

    respond_to do |format|
      format.csv { create_csv("scheduled-liaisons-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Scheduled Liaison'}
    end
  end

  def rosters
    @headers = get_headers_rosters
    @rows = get_rows_rosters

    respond_to do |format|
      format.csv { create_csv("rosters-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Rosters'}
    end
  end

  def get_headers_full_report
  # Find all liaisons and associated churches. Will contain duplicate church info if more than one liaison is
  # assigned to a church

      liaisons = Liaison.first
      @headers = []
      liaisons.attributes.each do |k, v|
        @headers << k.camelize
      end
      Church.first.attributes.each do |k, v|
        @headers << k.camelize
      end
      #logger.debug @headers.inspect
      return @headers
  end

  def get_rows_full_report
      @rows = []
      liaisons = Liaison.all
      liaisons.each do |l|
          row = []
          l.attributes.each do |k, v|
            row << trim(v)
          end
          if Church.exists?(l.church_id)
            Church.find(l.church_id).attributes.each do |k, v|
              row << trim(v)
            end
          end
          @rows << row
      end
      #logger.debug @rows
      return @rows
  end

  def get_headers_rosters

      @headers = []
      @headers << "Group Name" << "Current Total" << "Roster Items Entered" << "Missing (Extra)"
      return @headers
  end

  def get_rows_rosters

      @rows = []
      rosters = Roster.all
      rosters.each do |r|
        if r.scheduled_group
          row = []
          row << r.scheduled_group.name << r.scheduled_group.current_total << r.roster_items.count << (r.scheduled_group.current_total - r.roster_items.count)
          @rows << row
        end
      end
      return @rows
  end

  def get_headers_scheduled_liaisons

      @headers = []
      @headers << "Liaison Name" << "Church" << "Liaison Email"
      return @headers
  end

  def get_rows_scheduled_liaisons

      @rows = []
      liaisons = ScheduledGroup.active_program.active
      puts liaisons.count
      liaisons.each do |l|
          row = []
          row << l.liaison.name << l.church.name << l.liaison.email1
          @rows << row
      end
      @rows.uniq!
   end

  def participation_summary
    @headers = get_headers_part_sum
    @rows = get_rows_part_sum

    respond_to do |format|
      format.csv { create_csv("part-sum-#{Time.now.strftime("%Y%m%d")}.csv") }
      format.html { @title = 'Participation Summary'}
    end
  end


  def get_headers_part_sum

    @headers = []
    @headers << "Group Name" << "Church Name" << "Church Type" << "Site" << "Session Type" << "Youth" << "Counselors" << "Total" << "Roster Total"
    return @headers

  end

  def get_rows_part_sum

    @rows = []
    ScheduledGroup.active.each do |g|
        row = []
        row << g.name << g.church.name << g.church.church_type.name << g.session.site.name << g.session.session_type.name
        row << g.current_youth.to_i << g.current_counselors.to_i << g.current_total << Roster.find_by_group_id(g.id).roster_items.count << ""
        @rows << row
    end
    return @rows
  end

  def missing_churches(scope = nil)
    @headers = get_yty_headers
    @rows = get_yty_rows

    respond_to do |format|
      format.csv { create_csv("year-to-year-#{Time.now.strftime("%Y%m%d")}.csv") }
    end
  end
  def missing_churches_alt(scope = nil)
    @headers = get_yty_headers_alt
    @rows = get_yty_rows_alt

    respond_to do |format|
      format.csv { create_csv("year-to-year-#{Time.now.strftime("%Y%m%d")}.csv") }
    end
  end

  def get_yty_headers
    @headers = []
    @headers << "Church Name"
    @headers << "2012 JH Groups"
    @headers << "2012 JH Participants"
    @headers << "2013 JH Groups"
    @headers << "2013 JH Participants"
    @headers << "2012 SH Groups"
    @headers << "2012 SH Participants"
    @headers << "2013 SH Groups"
    @headers << "2013 SH Participants"
    @headers
  end

  def get_yty_rows
    @rows = []
    churches = Church.registered
    churches.each do |church|
      row = []
      row << church.name << ScheduledGroup.program_2012.junior_high.find_all_by_church_id(church.id).count
      row << (ScheduledGroup.program_2012.junior_high.find_all_by_church_id(church.id).map &:current_total).sum
      row << ScheduledGroup.active_program.junior_high.find_all_by_church_id(church.id).count
      row << (ScheduledGroup.active_program.junior_high.find_all_by_church_id(church.id).map &:current_total).sum
      row << ScheduledGroup.program_2012.senior_high.find_all_by_church_id(church.id).count
      row << (ScheduledGroup.program_2012.senior_high.find_all_by_church_id(church.id).map &:current_total).sum
      row << ScheduledGroup.active_program.senior_high.find_all_by_church_id(church.id).count
      row << (ScheduledGroup.active_program.senior_high.find_all_by_church_id(church.id).map &:current_total).sum
      row << ""
    @rows << row
    end
    @rows
  end

  def get_yty_headers_alt

    @headers = []
    @headers << "Group Name" << "Group Type"
    @headers << "Church" << "City"
    @headers << "Participants" << "Site"
    @headers << "Liaison Name" << "Liaison Work Phone" << "Liaison Cell Phone" << "Liaison Email"
    @headers
  end

  def get_yty_rows_alt
    @rows = []
    missing = ScheduledGroup.program_2012.joins(:church).where('churches.registered = ?', false)

    missing.each do |group|
      row = []
      row << group.name << group.session_type.name
      row << group.church.name << group.church.city
      row << group.current_total << group.session.site.name
      row << group.liaison.name << group.liaison.work_phone << group.liaison.cell_phone << group.liaison.email1
      row << ""
    @rows << row
    end
    @rows
  end

  def new_churches
    @headers = get_new_churches_headers
    logger.debug @headers.inspect
    @rows = get_new_churches_rows

    respond_to do |format|
      format.csv { create_csv("new-churches-#{Time.now.strftime("%Y%m%d")}.csv") }
    end
  end

  def get_new_churches_headers
    @headers = []
    @headers << "Church Name"
    @headers << "Group Name"
    @headers << "Group Type"
    @headers << "2013 Total"
    @headers << "Liaison Email"
    return @headers
  end

  def get_new_churches_rows
    @rows = []
    Registration.current.each do |group|
      unless ScheduledGroup.find_by_church_id_and_group_type_id(group.church_id, group.group_type_id)
        row = []
        row << group.church.name << group.name << group.session_type.name << group.requested_total.to_i << group.liaison.email1 << ""
        @rows << row
      end
    end
    return @rows
  end

  private
  def trim(s)
    if s.instance_of?(String)
      s.chomp.strip!
    end
    return s
  end

  def create_csv(filename = nil)
      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain"
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = "0"
      else
        headers["Content-Type"] ||= 'text/csv'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      end
  end
end
