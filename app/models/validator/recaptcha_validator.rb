class Validator::RecaptchaValidator < Validator
  def validate(record)
    unless record.recaptcha == 'true'
      record.errors[:base] << I18n.t('activerecord.errors.messages.recaptcha')
    end
  end
end

