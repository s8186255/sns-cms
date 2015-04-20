require 'test_helper'

class UserFunctionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_functions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_function" do
    assert_difference('UserFunction.count') do
      post :create, :user_function => { }
    end

    assert_redirected_to user_function_path(assigns(:user_function))
  end

  test "should show user_function" do
    get :show, :id => user_functions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_functions(:one).to_param
    assert_response :success
  end

  test "should update user_function" do
    put :update, :id => user_functions(:one).to_param, :user_function => { }
    assert_redirected_to user_function_path(assigns(:user_function))
  end

  test "should destroy user_function" do
    assert_difference('UserFunction.count', -1) do
      delete :destroy, :id => user_functions(:one).to_param
    end

    assert_redirected_to user_functions_path
  end
end
