require File.dirname(__FILE__) + '/../test_helper'

class User2Test < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :user2s

  def test_should_create_user2
    assert_difference 'User2.count' do
      user2 = create_user2
      assert !user2.new_record?, "#{user2.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user2 = create_user2
    user2.reload
    assert_not_nil user2.activation_code
  end

  def test_should_require_login
    assert_no_difference 'User2.count' do
      u = create_user2(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User2.count' do
      u = create_user2(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User2.count' do
      u = create_user2(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User2.count' do
      u = create_user2(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    user2s(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal user2s(:quentin), User2.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    user2s(:quentin).update_attributes(:login => 'quentin2')
    assert_equal user2s(:quentin), User2.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user2
    assert_equal user2s(:quentin), User2.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    user2s(:quentin).remember_me
    assert_not_nil user2s(:quentin).remember_token
    assert_not_nil user2s(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    user2s(:quentin).remember_me
    assert_not_nil user2s(:quentin).remember_token
    user2s(:quentin).forget_me
    assert_nil user2s(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    user2s(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil user2s(:quentin).remember_token
    assert_not_nil user2s(:quentin).remember_token_expires_at
    assert user2s(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    user2s(:quentin).remember_me_until time
    assert_not_nil user2s(:quentin).remember_token
    assert_not_nil user2s(:quentin).remember_token_expires_at
    assert_equal user2s(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    user2s(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil user2s(:quentin).remember_token
    assert_not_nil user2s(:quentin).remember_token_expires_at
    assert user2s(:quentin).remember_token_expires_at.between?(before, after)
  end

protected
  def create_user2(options = {})
    record = User2.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
