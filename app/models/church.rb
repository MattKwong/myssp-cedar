# == Schema Information
#
# Table name: churches
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  city           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  liaison_id     :integer
#  address2       :string(255)
#  state          :string(255)
#  zip            :string(255)
#  office_phone   :string(255)
#  fax            :string(255)
#  email1         :string(255)
#  address1       :string(255)
#  active         :boolean
#  registered     :boolean
#  church_type_id :integer
#

class Church < ActiveRecord::Base

  #default_scope :order => 'name'
  has_many :liaisons
  has_many :registrations
  has_many :scheduled_groups
  accepts_nested_attributes_for :liaisons
  accepts_nested_attributes_for :registrations
  accepts_nested_attributes_for :scheduled_groups

  belongs_to :church_type
  scope :inactive, where(:active => 'f')
  scope :unregistered, where(:registered => 'f')
  scope :active, where(:active => 't')

  scope :registered, where(:registered => 't')

  attr_accessible :name, :active, :address1, :address2, :city, :email1, :fax,
                    :church_type_id, :liaison_id, :office_phone, :state, :zip,
                    :registered
  before_validation do
    self.state = self.state.upcase.first(2)
  end

  validates :name,  :presence => true,
                    :length => { :within => 6..45},
                    :uniqueness => true
  validates :address1, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true,
                    :length => { :is => 2}
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates :zip,   :presence => true,
                    :length => { :is => 5},
                    :numericality => true
  validates :email1, :uniqueness => true
  validates_format_of :email1,
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => 'Email appears to be invalid.', :allow_blank => true

  #validates_format_of :office_phone, :with => /\A[0-9]{3}-[0-9]{3}-[0-9]{4}/,
  #                    :message => 'Please enter phone numbers in the 123-456-7890 format.',
  #                    :allow_blank => false
  #
  #validates_format_of :fax, :with => /\A[0-9]{3}-[0-9]{3}-[0-9]{4}/,
  #                    :message => 'Please enter phone numbers in the 123-456-7890 format.',
  #                    :allow_blank => true

#  validates :liaison_id, :presence => true
  validates :church_type_id, :presence => true
  before_validation do
    if self.office_phone[0..1] == '1-'
      self.office_phone[0..1] = ''
    end
    if self.fax[0..1] == '1-'
      self.fax[0..1] = ''
    end

    self.state = self.state.upcase.first(2)
    self.office_phone = self.office_phone.gsub(/\D/,'')
    self.fax = self.fax.gsub(/\D/,'')
  end
  before_save :format_phone_numbers

  def format_phone_numbers
    unless self.office_phone == ""
      self.office_phone = self.office_phone.insert 6, '-'
      self.office_phone = self.office_phone.insert 3, '-'
    end
    unless self.fax == ""
      self.fax = self.fax.insert 6, '-'
      self.fax = self.fax.insert 3, '-'
    end
  end

end
