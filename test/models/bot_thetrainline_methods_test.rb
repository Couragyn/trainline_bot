require "test_helper"

class BotThetrainlineMethodsTest < ActiveSupport::TestCase
  test "validate_search_params: delegates to validator and returns errors" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2026-02-22T09:00:00+01:00")
    assert_empty errors

    errors = Bot::Thetrainline.validate_search_params("", "Barcelona", "2026-02-22T09:00:00+01:00")
    assert_not_empty errors
    assert_includes errors, "Departure city or station is required"
  end

  test "parse_departure_at: delegates to validator and parses dates" do
    result = Bot::Thetrainline.parse_departure_at("2026-02-22T09:00:00+01:00")
    assert_instance_of DateTime, result
    assert_equal 2026, result.year

    result = Bot::Thetrainline.parse_departure_at("not-a-date")
    assert_nil result
  end
end
