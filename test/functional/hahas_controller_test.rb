require 'test_helper'

class HahasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hahas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create haha" do
    assert_difference('Haha.count') do
      post :create, :haha => { }
    end

    assert_redirected_to haha_path(assigns(:haha))
  end

  test "should show haha" do
    get :show, :id => hahas(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => hahas(:one).to_param
    assert_response :success
  end

  test "should update haha" do
    put :update, :id => hahas(:one).to_param, :haha => { }
    assert_redirected_to haha_path(assigns(:haha))
  end

  test "should destroy haha" do
    assert_difference('Haha.count', -1) do
      delete :destroy, :id => hahas(:one).to_param
    end

    assert_redirected_to hahas_path
  end
end
