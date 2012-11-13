# == Schema Information
#
# Table name: sites
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  address1         :string(255)
#  address2         :string(255)
#  city             :string(255)
#  state            :string(255)
#  zip              :string(255)
#  phone            :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  listing_priority :integer
#  active           :boolean
#  summer_domestic  :boolean
#  abbr             :string(255)
#

class Site < ActiveRecord::Base
  default_scope :order => 'listing_priority'
  scope :inactive, where(:active => 'f')
  scope :active, where(:active => 't')
  scope :summer_domestic, where(:summer_domestic => 't')


  has_many :sessions
  has_many :admin_users
  has_many :vendors
  has_many :programs

  accepts_nested_attributes_for :sessions

  attr_accessible :id, :address1, :address2, :city, :name, :phone, :state,
                  :zip, :listing_priority, :active, :summer_domestic, :abbr

  validates :name, :address1, :city, :state, :zip, :listing_priority, :abbr, :presence => true

  validates :state, :abbr, :length => { :is => 2}
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates :zip,   :length => { :is => 5}, :numericality => true

  validates_format_of :phone, :with => /\A[0-9]{3}-[0-9]{3}-[0-9]{4}/,
                      :message => 'Please enter phone numbers in the 123-456-7890 format.'
  validates :listing_priority, :numericality => true

  #def self.sites_for_group_type(group_type)
  #  sites = Array.new
  #  #TODO: Currently this picks  up inactive sites
  #  Site.active.each do |site|
  #    if site.sessions.each do |session|
  #      if session.session_type_id == group_type.to_i
  #        sites.push(site)
  #      end
  #    end
  #    end
  #  end
  #  sites.uniq
  #
  #end
  #
  #def self.sites_for_group_type_senior
  #  group_type = SessionType.find_by_name("Summer Senior High").id
  #  self.sites_for_group_type(group_type)
  #end


end
