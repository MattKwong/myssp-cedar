# == Schema Information
#
# Table name: periods
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  start_date      :datetime
#  end_date        :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  active          :boolean
#  summer_domestic :boolean
#

class Period < ActiveRecord::Base
  attr_accessible :name, :start_date, :end_date, :active, :summer_domestic
  default_scope :order => 'start_date'
  has_many :sessions
  accepts_nested_attributes_for :sessions
  scope :active, where(:active => true)
  scope :summer_domestic, where(:summer_domestic => true)
  scope :other, where(:summer_domestic => false)

  validates :name, :start_date, :end_date, :presence => true
  validate :start_date_before_end_date
  validate :start_date_not_in_past

  def start_date_before_end_date
    unless start_date.nil? or end_date.nil?
      unless start_date <= end_date
        errors.add(:end_date, "End date must be after the start date")
      end
    end
  end

  def start_date_not_in_past
     unless start_date.nil?
       if start_date < Date.today
        errors.add(:start_date, "Start date cannot be in the past")
       end
    end
  end

  def self.find_all_hosting(program_type)
    periods = Array.new
    Session.find_all_by_program_type(program_type).each do |session|
      periods << session.period
    end
    periods.uniq!
    if periods.count > 1
      periods.sort_by!{|p| p[:start_date]}
    end
    periods
  end

  def self.summer_domestic
    active.find_all_hosting("Summer Domestic")
  end

  def self.weekend_of_service
    active.find_all_hosting("Weekend of Service")
  end

end
