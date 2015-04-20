class UserTestObserver < ActiveRecord::Observer
  def after_create(user_test)
    UserTestMailer.deliver_signup_notification(user_test)
  end

  def after_save(user_test)
  
    UserTestMailer.deliver_activation(user_test) if user_test.recently_activated?
  
  end
end
