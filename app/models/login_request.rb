class LoginRequest < ActiveRecord::Base
  attr_accessible :approved, :church_name, :church_address1, :church_address2,
                  :church_city,  :church_state, :church_zip, :church_office_phone, :church_office_fax,
                  :first_name, :last_name, :address1, :address2, :city, :state, :zip,
                  :phone_number, :phone_number_type, :alt_phone_number, :alt_phone_number_type, :email,
                  :how_heard, :user_created

  scope :unprocessed, where(:user_created => [false, nil])

  validates :church_name, :church_address1, :church_city,  :church_state, :church_zip,
            :first_name, :last_name, :address1, :city, :state, :zip, :phone_number, :phone_number_type,
            :church_office_phone, :presence => true
  validates :email, :presence => true, :uniqueness => true
  validates_inclusion_of :state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates_inclusion_of :church_state, :in => State::STATE_ABBREVIATIONS, :message => 'Invalid state.'
  validates_inclusion_of :phone_number_type, :in => PhoneType::NAMES, :message => 'Invalid phone type.'
  validates_inclusion_of :alt_phone_number_type, :in => PhoneType::NAMES, :message => 'Invalid phone type.', :allow_blank =>  true
  validates :zip,   :presence => true,
            :length => { :is => 5},
            :numericality => true
  validates :church_zip,   :presence => true,
            :length => { :is => 5},
            :numericality => true
  validates_format_of :email,
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                      :message => 'Email appears to be invalid.'

  validates_numericality_of :phone_number, :alt_phone_number, :church_office_phone, :church_office_fax,
                            :message => 'Phone number must be 10 digits plus optional separators.',
                            :allow_blank => true

  validates_length_of :phone_number, :alt_phone_number, :church_office_phone, :church_office_fax,
                      :is => 10,
                      :message => 'Phone number must be 10 digits plus optional separators.',
                      :allow_blank => true
  validate :duplicate_phone_types

  before_validation do
    #if self.alt_phone_number == ""
    #  self.alt_phone_number_type = ""
    #end

    if self.phone_number[0..1] == '1-'
      self.phone_number[0..1] = ''
    end
    if self.alt_phone_number[0..1] == '1-'
      self.alt_phone_number[0..1] = ''
    end
    if self.church_office_phone && self.church_office_phone[0..1] == '1-'
      self.church_office_phone[0..1] = ''
    end
    if self.church_office_fax[0..1] == '1-'
      self.church_office_fax[0..1] = ''
    end

    self.phone_number = self.phone_number.gsub(/\D/,'')
    self.alt_phone_number= self.alt_phone_number.gsub(/\D/,'') if self.alt_phone_number
    self.church_office_phone = self.church_office_phone.gsub(/\D/,'') if self.church_office_phone
    self.church_office_fax = self.church_office_fax.gsub(/\D/,'') if self.church_office_fax
  end

  validate :alt_type_and_number_match

  def alt_type_and_number_match
    if self.alt_phone_number_type != "" && self.alt_phone_number == ""
      errors.add(:alt_phone_number, "You have specified a phone number type without a phone number.")
    end
    if self.alt_phone_number != "" && self.alt_phone_number_type == ""
      errors.add(:alt_phone_number_type, "You have specified a phone number without a phone number type.")
    end
  end

  def duplicate_phone_types
    if self.phone_number_type == self.alt_phone_number_type
      errors.add(:alt_phone_number_type, "You have already input a #{self.alt_phone_number_type} phone number.")
    end
  end

end
