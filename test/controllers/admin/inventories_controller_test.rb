require "test_helper"

class Admin::InventoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get admin_inventories_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_inventories_update_url
    assert_response :success
  end
end
