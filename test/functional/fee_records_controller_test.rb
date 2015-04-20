require 'test_helper'

class FeeRecordsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fee_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fee_record" do
    assert_difference('FeeRecord.count') do
      post :create, :fee_record => { }
    end

    assert_redirected_to fee_record_path(assigns(:fee_record))
  end

  test "should show fee_record" do
    get :show, :id => fee_records(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fee_records(:one).to_param
    assert_response :success
  end

  test "should update fee_record" do
    put :update, :id => fee_records(:one).to_param, :fee_record => { }
    assert_redirected_to fee_record_path(assigns(:fee_record))
  end

  test "should destroy fee_record" do
    assert_difference('FeeRecord.count', -1) do
      delete :destroy, :id => fee_records(:one).to_param
    end

    assert_redirected_to fee_records_path
  end
end
