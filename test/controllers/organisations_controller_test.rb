require "test_helper"

class OrganisationsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get organisations_edit_url
    assert_response :success
  end

  test "should get update" do
    get organisations_update_url
    assert_response :success
  end
end
