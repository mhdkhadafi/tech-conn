require 'test_helper'

class ConnectionsControllerTest < ActionController::TestCase
  setup do
    @connection = connections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:connections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create connection" do
    assert_difference('Connection.count') do
      post :create, connection: { cfirstname: @connection.cfirstname, clastname: @connection.clastname, company: @connection.company, pfirstname: @connection.pfirstname, plastname: @connection.plastname }
    end

    assert_redirected_to connection_path(assigns(:connection))
  end

  test "should show connection" do
    get :show, id: @connection
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @connection
    assert_response :success
  end

  test "should update connection" do
    patch :update, id: @connection, connection: { cfirstname: @connection.cfirstname, clastname: @connection.clastname, company: @connection.company, pfirstname: @connection.pfirstname, plastname: @connection.plastname }
    assert_redirected_to connection_path(assigns(:connection))
  end

  test "should destroy connection" do
    assert_difference('Connection.count', -1) do
      delete :destroy, id: @connection
    end

    assert_redirected_to connections_path
  end
end
