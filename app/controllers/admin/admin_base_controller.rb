class Admin::AdminBaseController< ApplicationController
  before_filter:login_required
  #layout 'admin'
end
