class Validator::SupporterValidator < Validator
  validates_with Validator::RecaptchaValidator

  attr_accessor(
      :first,
      :last_name,
      :affiliation,
      :occupation,
      :recaptcha
  )

  validates(
      :first_name,
      :last_name,
      :affiliation,
      :presence => true
  )

end

