class UserTestMailer < ActionMailer::Base
  def signup_notification(user_test)
    setup_email(user_test)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{user_test.activation_code}"
  
  end
  
  def activation(user_test)
    setup_email(user_test)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end
  
  protected
    def setup_email(user_test)
      @recipients  = "#{user_test.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:user_test] = user_test
    end
end
