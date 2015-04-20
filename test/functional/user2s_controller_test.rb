require File.dirname(__FILE__) + '/../test_helper'
require 'user2s_controller'

# Re-raise errors caught by the controller.
class User2sController; def rescue_action(e) raise e end; end

class User2sControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :user2s

  def setup
    @controller = User2sController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    assert_difference 'User2.count' do
      create_user2
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User2.count' do
      create_user2(:login => nil)
      assert assigns(:user2).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User2.count' do
      create_user2(:password => nil)
      assert assigns(:user2).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User2.count' do
      create_user2(:password_confirmation => nil)
      assert assigns(:user2).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User2.count' do
      create_user2(:email => nil)
      assert assigns(:user2).errors.on(:email)
      assert_response :success
    end
  end
  

  
  def test_should_sign_up_user_with_activation_code
    create_user2
    assigns(:user2).reload
    assert_not_nil assigns(:user2).activation_code
  end

  def test_should_activate_user
    assert_nil User2.authenticate('aaron', 'test')
    get :activate, :activation_code => user2s(:aaron).activation_code
    assert_redirected_to '/'
    assert_not_nil flash[:notice]
    assert_equal user2s(:aaron), User2.authenticate('aaron', 'test')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end

  protected
    def create_user2(options = {})
      post :create, :user2 => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
