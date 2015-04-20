class User3Mailer < ActionMailer::Base
  def signup_notification(user3)
    setup_email(user3)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://YOURSITE/activate/#{user3.activation_code}"
  
  end
  
  def activation(user3)
    setup_email(user3)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://YOURSITE/"
  end
  
  protected
    def setup_email(user3)
      @recipients  = "#{user3.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[YOURSITE] "
      @sent_on     = Time.now
      @body[:user3] = user3
    end
end
