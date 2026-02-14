require "test_helper"

class Bot::ThetrainlineTest < ActiveSupport::TestCase
  def setup
    @departure_date = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
    @fixture_segments = find_fixture_route("Madrid", "Barcelona", @departure_date)
  end

  test "find returns an array using fixture data" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)
    assert_kind_of Array, result

    assert result.any?, "Should have results from fixture data"
    assert_equal @fixture_segments.length, result.length
  end

  test "find returns empty array for non-existent route not in fixture" do
    result = Bot::Thetrainline.find("Madrid", "NonExistentCity", @departure_date)
    assert_equal [], result
  end

  test "find returns empty array for invalid date not in fixture data" do
    invalid_date = DateTime.new(2026, 3, 25, 9, 0, 0, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", invalid_date)
    assert_equal [], result
  end

  test "segment contains all required fields from fixture data of the correct type" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)
    assert result.any?, "Should have at least one result from fixture"

    segment = result.first
    assert segment.key?(:departure_station)
    assert_kind_of String, segment[:departure_station]

    assert segment.key?(:departure_at)
    assert_kind_of DateTime, segment[:departure_at]

    assert segment.key?(:arrival_station)
    assert_kind_of String, segment[:arrival_station]

    assert segment.key?(:arrival_at)
    assert_kind_of DateTime, segment[:arrival_at]

    assert segment.key?(:service_agencies)
    assert_kind_of Array, segment[:service_agencies]

    assert segment.key?(:duration_in_minutes)
    assert_kind_of Integer, segment[:duration_in_minutes]

    assert segment.key?(:changeovers)
    assert_kind_of Integer, segment[:changeovers]

    assert segment.key?(:products)
    assert_kind_of Array, segment[:products]

    assert segment.key?(:fares)
    assert_kind_of Array, segment[:fares]

    fare = segment[:fares].first
    assert fare.key?(:name)
    assert_kind_of String, fare[:name]

    assert fare.key?(:price_in_cents)
    assert_kind_of Integer, fare[:price_in_cents]

    assert fare.key?(:currency)
    assert_kind_of String, fare[:currency]
  end

  test "find is case-insensitive for cities in fixture data" do
    result1 = Bot::Thetrainline.find("madrid", "barcelona", @departure_date)
    result2 = Bot::Thetrainline.find("MADRID", "BARCELONA", @departure_date)
    result3 = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)

    assert_equal result1.length, result2.length, "Results should be same case-insensitive"
    assert_equal result1.length, result3.length, "Results should be same case-insensitive"
  end

  test "segments are sorted by departure time from fixture data" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)

    assert result.any?, "Should have results from fixture"

    result.each_cons(2) do |segment1, segment2|
      assert_operator segment1[:departure_at], :<=, segment2[:departure_at]
    end
  end

  test "fare prices are positive integers from fixture data" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)
    segment = result.first

    segment[:fares].each do |fare|
      assert_operator fare[:price_in_cents], :>, 0, "Price should be positive in fixture"
      assert_kind_of Integer, fare[:price_in_cents]
    end
  end

  test "fixture data contain valid values" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)
    segment = result.first

    time_diff_days = (segment[:arrival_at] - segment[:departure_at])
    expected_duration = (time_diff_days.to_f * 24 * 60).to_i
    assert_equal segment[:duration_in_minutes], expected_duration, "Duration in fixture should match time difference"

    assert segment[:service_agencies].include?("thetrainline"), "Fixture should include thetrainline agency"
    assert segment[:products].include?("train"), "Fixture should include train product"
    assert_operator segment[:arrival_at], :>, segment[:departure_at], "Fixture arrival should be after departure"

    result.each do |segment|
      assert_operator segment[:changeovers], :>=, 0, "Changeovers in fixture should be non-negative"
    end
  end

  test "fixture data loads successfully" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @departure_date)
    assert result.any?, "Fixture data should load and return results"

    raw_fixture = fixture_data
    assert raw_fixture.key?("segments"), "Fixture should have segments"
    assert raw_fixture["segments"].any?, "Fixture segments should not be empty"
  end
end
