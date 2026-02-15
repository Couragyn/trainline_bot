require "test_helper"

class TrainSearchValidatorTest < ActiveSupport::TestCase
  test "valid?: accepts valid search parameters" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "2026-02-22T09:00:00+01:00")
    assert validator.valid?
    assert_empty validator.errors
  end

  test "valid?: rejects blank from location" do
    validator = TrainSearchValidator.new("", "Barcelona", "2026-02-22T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Departure city or station is required"
  end

  test "valid?: rejects blank to location" do
    validator = TrainSearchValidator.new("Madrid", "", "2026-02-22T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Arrival city or station is required"
  end

  test "valid?: rejects blank departure date" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "")
    refute validator.valid?
    assert_includes validator.errors, "Departure date and time is required"
  end

  test "valid?: rejects date before minimum allowed date" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "2026-02-15T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Departure date cannot be before February 16, 2026"
  end

  test "valid?: rejects date after maximum allowed date" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "2027-02-23T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Departure date cannot be after February 22, 2027"
  end

  test "valid?: rejects invalid date format" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "not-a-date")
    refute validator.valid?
    assert_includes validator.errors, "Invalid date and time format"
  end

  test "valid?: rejects same from and to location" do
    validator = TrainSearchValidator.new("Madrid", "madrid", "2026-02-22T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Departure and arrival locations must be different"
  end

  test "valid?: rejects same location with different case" do
    validator = TrainSearchValidator.new("MADRID", "madrid", "2026-02-22T09:00:00+01:00")
    refute validator.valid?
    assert_includes validator.errors, "Departure and arrival locations must be different"
  end

  test "valid?: accepts date exactly at minimum allowed date" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "2026-02-16T00:00:00+01:00")
    assert validator.valid?
  end

  test "valid?: accepts date exactly at maximum allowed date" do
    validator = TrainSearchValidator.new("Madrid", "Barcelona", "2027-02-22T00:00:00+01:00")
    assert validator.valid?
  end

  test "parse_departure_at: parses valid datetime string" do
    result = TrainSearchValidator.parse_departure_at("2026-02-22T09:00:00+01:00")
    assert_instance_of DateTime, result
    assert_equal 2026, result.year
    assert_equal 2, result.month
    assert_equal 22, result.day
    assert_equal 9, result.hour
  end

  test "parse_departure_at: returns nil for blank string" do
    result = TrainSearchValidator.parse_departure_at("")
    assert_nil result
  end

  test "parse_departure_at: returns nil for nil" do
    result = TrainSearchValidator.parse_departure_at(nil)
    assert_nil result
  end

  test "parse_departure_at: returns nil for invalid date format" do
    result = TrainSearchValidator.parse_departure_at("not-a-date")
    assert_nil result
  end

  test "parse_departure_at: parses various datetime formats" do
    result = TrainSearchValidator.parse_departure_at("2026-02-22 09:00:00")
    assert_instance_of DateTime, result
  end
end
