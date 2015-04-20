class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject += '请点击下面链接激活你的帐号'
  
    @body[:url]  = "http://#{SITE_URL}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += '你的帐号已被激活!'
    @body[:url]  = "http://#{SITE_URL}/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "saq@xj.cninfo.net"
      @subject     = "[#{SITE_URL}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
