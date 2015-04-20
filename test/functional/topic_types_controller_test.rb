require 'test_helper'

class TopicTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:topic_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create topic_type" do
    assert_difference('TopicType.count') do
      post :create, :topic_type => { }
    end

    assert_redirected_to topic_type_path(assigns(:topic_type))
  end

  test "should show topic_type" do
    get :show, :id => topic_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => topic_types(:one).to_param
    assert_response :success
  end

  test "should update topic_type" do
    put :update, :id => topic_types(:one).to_param, :topic_type => { }
    assert_redirected_to topic_type_path(assigns(:topic_type))
  end

  test "should destroy topic_type" do
    assert_difference('TopicType.count', -1) do
      delete :destroy, :id => topic_types(:one).to_param
    end

    assert_redirected_to topic_types_path
  end
end
