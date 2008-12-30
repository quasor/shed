require 'test_helper'

class IntervalsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:intervals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create interval" do
    assert_difference('Interval.count') do
      post :create, :interval => { }
    end

    assert_redirected_to interval_path(assigns(:interval))
  end

  test "should show interval" do
    get :show, :id => intervals(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => intervals(:one).id
    assert_response :success
  end

  test "should update interval" do
    put :update, :id => intervals(:one).id, :interval => { }
    assert_redirected_to interval_path(assigns(:interval))
  end

  test "should destroy interval" do
    assert_difference('Interval.count', -1) do
      delete :destroy, :id => intervals(:one).id
    end

    assert_redirected_to intervals_path
  end
end
