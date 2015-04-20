ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => "mail.xj.cninfo.net",
    :port => 25,
    :domain => "mail.xj.cninfo.net",
    :authentication => :plain,
    :user_name => "saq",
    :password => "wei720503"
}
