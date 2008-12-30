require 'test_helper'

class ProjectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create projection" do
    assert_difference('Projection.count') do
      post :create, :projection => { }
    end

    assert_redirected_to projection_path(assigns(:projection))
  end

  test "should show projection" do
    get :show, :id => projections(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => projections(:one).id
    assert_response :success
  end

  test "should update projection" do
    put :update, :id => projections(:one).id, :projection => { }
    assert_redirected_to projection_path(assigns(:projection))
  end

  test "should destroy projection" do
    assert_difference('Projection.count', -1) do
      delete :destroy, :id => projections(:one).id
    end

    assert_redirected_to projections_path
  end
end
