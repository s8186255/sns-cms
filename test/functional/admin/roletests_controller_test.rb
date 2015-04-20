require 'test_helper'

class Admin::RoletestsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_roletests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create roletest" do
    assert_difference('Admin::Roletest.count') do
      post :create, :roletest => { }
    end

    assert_redirected_to roletest_path(assigns(:roletest))
  end

  test "should show roletest" do
    get :show, :id => admin_roletests(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_roletests(:one).to_param
    assert_response :success
  end

  test "should update roletest" do
    put :update, :id => admin_roletests(:one).to_param, :roletest => { }
    assert_redirected_to roletest_path(assigns(:roletest))
  end

  test "should destroy roletest" do
    assert_difference('Admin::Roletest.count', -1) do
      delete :destroy, :id => admin_roletests(:one).to_param
    end

    assert_redirected_to admin_roletests_path
  end
end
