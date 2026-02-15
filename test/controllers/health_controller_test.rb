require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get health check status" do
    get health_check_path
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "ok", json_response["status"]
    assert json_response["timestamp"]
  end

  test "should get deep health check with all systems healthy" do
    get deep_health_check_path
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "ok", json_response["status"]
    assert json_response["checks"]["cache"]
    assert json_response["checks"]["train_data"]
  end
end
