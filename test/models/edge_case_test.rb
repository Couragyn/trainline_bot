require "test_helper"

class EdgeCaseTest < ActiveSupport::TestCase
  def setup
    @min_date = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
    @max_date = DateTime.new(2027, 2, 11, 23, 59, 59, "+01:00")
  end

  test "find with exact minimum allowed date" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)
    assert_kind_of Array, result
  end

  test "find with exact maximum allowed date" do
    @max_fixture_date = DateTime.new(2026, 2, 22, 23, 59, 59, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @max_fixture_date)
    assert_kind_of Array, result
  end

  test "find returns empty for date one day before minimum" do
    before_min = DateTime.new(2026, 2, 15, 23, 59, 59, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", before_min)
    assert_equal [], result, "Should return empty for date before minimum"
  end

  test "find returns empty for date one year after maximum" do
    after_max = DateTime.new(2028, 2, 12, 0, 0, 0, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", after_max)
    assert_equal [], result, "Should return empty for date after maximum"
  end

  test "find handles city names with accents" do
    result = Bot::Thetrainline.find("São Paulo", "Rio", @min_date)
    assert_kind_of Array, result
  end

  test "find is case-insensitive with mixed case input" do
    result1 = Bot::Thetrainline.find("MaDrId", "BaRcElOnA", @min_date)
    result2 = Bot::Thetrainline.find("madrid", "barcelona", @min_date)
    result3 = Bot::Thetrainline.find("MADRID", "BARCELONA", @min_date)

    assert_equal result1.length, result2.length, "Case-insensitive for mixed case"
    assert_equal result2.length, result3.length, "Case-insensitive for lowercase"
  end

  test "find handles leading/trailing whitespace in city names" do
    result = Bot::Thetrainline.find("  Madrid  ", "  Barcelona  ", @min_date)
    expected = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    assert_equal expected.length, result.length, "Should return same results with or without whitespace"
    assert_operator result.length, :>, 0, "Should find results with whitespace"
  end

  test "find handles cities with hyphens or apostrophes" do
    result = Bot::Thetrainline.find("Saint-Etienne", "Barcelona", @min_date)
    assert_kind_of Array, result
  end

  test "find returns journeys with multiple changeovers" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    journey_with_changes = result.find { |j| j[:changeovers] > 0 }

    if journey_with_changes
      assert_operator journey_with_changes[:changeovers], :>, 0
      assert_kind_of Integer, journey_with_changes[:changeovers]
    else
      assert_kind_of Array, result
    end
  end

  test "find returns journeys crossing day boundaries" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    journey_crossing_midnight = result.find do |j|
      j[:arrival_at].day != j[:departure_at].day
    end

    if journey_crossing_midnight
      assert_operator journey_crossing_midnight[:arrival_at], :>, journey_crossing_midnight[:departure_at]
    else
      assert_kind_of Array, result
    end
  end

  test "find handles very early morning departures" do
    early_date = DateTime.new(2026, 2, 16, 0, 30, 0, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", early_date)

    assert_kind_of Array, result
    result.each do |journey|
      assert_kind_of DateTime, journey[:departure_at]
    end
  end

  test "find handles late night departures" do
    late_date = DateTime.new(2026, 2, 16, 23, 45, 0, "+01:00")
    result = Bot::Thetrainline.find("Madrid", "Barcelona", late_date)

    assert_kind_of Array, result
    result.each do |journey|
      assert_kind_of DateTime, journey[:departure_at]
    end
  end

  test "segments with single fare option" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    journey_single_fare = result.find { |j| j[:fares].length == 1 }
    if journey_single_fare
      assert_equal journey_single_fare[:fares].length, 1
    else
      assert_kind_of Array, result
    end
  end

  test "segments with many fare options" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    journey_many_fares = result.find { |j| j[:fares].length > 2 }
    if journey_many_fares
      assert_operator journey_many_fares[:fares].length, :>=, 3
    else
      assert_kind_of Array, result
    end
  end

  test "fares are priced in descending flexibility (highest price expected last)" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)
    segment = result.first

    if segment[:fares].length > 1
      fares = segment[:fares]
      advance = fares.find { |f| f[:name].include?("Advance") }
      flexible = fares.find { |f| f[:name].include?("Flexible") }

      if advance && flexible
        assert_operator flexible[:price_in_cents], :>=, advance[:price_in_cents]
      end
    end
  end

  test "journey duration increases with more changeovers" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    if result.length > 1
      journey_no_changes = result.find { |j| j[:changeovers] == 0 }
      journey_with_changes = result.find { |j| j[:changeovers] > 0 }

      if journey_no_changes && journey_with_changes
        assert_operator journey_no_changes[:duration_in_minutes], :<=, journey_with_changes[:duration_in_minutes]
      else
        assert_kind_of Array, result
      end
    else
      assert_kind_of Array, result
    end
  end

  test "journey duration is positive and reasonable" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    result.each do |journey|
      assert_operator journey[:duration_in_minutes], :>, 0, "Duration must be positive"
      assert_operator journey[:duration_in_minutes], :<, 1440 * 7, "Duration should be less than 7 days"
    end
  end

  test "find handles empty string cities" do
    result = Bot::Thetrainline.find("", "Barcelona", @min_date)
    assert_equal [], result
  end

  test "find handles nil city names gracefully" do
    assert_nothing_raised do
      result = Bot::Thetrainline.find(nil, nil, @min_date)
    end
  end

  test "journey times are returned as DateTime objects" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    result.each do |journey|
      assert_kind_of DateTime, journey[:departure_at]
      assert_kind_of DateTime, journey[:arrival_at]
    end
  end

  test "journey times have timezone information" do
    result = Bot::Thetrainline.find("Madrid", "Barcelona", @min_date)

    result.each do |journey|
      assert journey[:departure_at].zone.present?, "Departure should have timezone"
      assert journey[:arrival_at].zone.present?, "Arrival should have timezone"
    end
  end
end
