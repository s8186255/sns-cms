module AuthenticatedTestHelper
  # Sets the current user2 in the session from the user2 fixtures.
  def login_as(user2)
    @request.session[:user2_id] = user2 ? user2s(user2).id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
