class User3Observer < ActiveRecord::Observer
  def after_create(user3)
    User3Mailer.deliver_signup_notification(user3)
  end

  def after_save(user3)
  
    User3Mailer.deliver_activation(user3) if user3.recently_activated?
  
  end
end
