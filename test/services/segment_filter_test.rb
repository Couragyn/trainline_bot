require "test_helper"

class SegmentFilterTest < ActiveSupport::TestCase
  def setup
    @from = "Madrid"
    @to = "Barcelona"
    @date = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
    @filter = SegmentFilter.new(@from, @to, @date)
  end

  test "filter: returns segments matching all criteria" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 1, result.length
  end

  test "filter: excludes segments without matching route" do
    segments = [
      {
        "departure_city" => "Valencia",
        "departure_station" => "Joaquín Sorolla",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Sevilla",
        "arrival_station" => "Santa Justa",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 0, result.length
  end

  test "filter: excludes segments without matching date" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-17T09:00:00+01:00",  # Different date
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-17T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 0, result.length
  end

  test "filter: excludes segments without fares" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => []
      }
    ]

    result = @filter.filter(segments)
    assert_equal 0, result.length
  end

  test "filter: matches case-insensitively" do
    filter = SegmentFilter.new("MADRID", "barcelona", @date)

    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = filter.filter(segments)
    assert_equal 1, result.length
  end

  test "filter: matches by station name" do
    filter = SegmentFilter.new("Atocha", "Sants", @date)

    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = filter.filter(segments)
    assert_equal 1, result.length
  end

  test "filter: ignores time differences on same date" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T14:30:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T18:30:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 1, result.length
  end

  test "filter: handles multiple segments" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      },
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "2026-02-16T14:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T18:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      },
      {
        "departure_city" => "Valencia",
        "departure_station" => "Joaquín Sorolla",
        "departure_at" => "2026-02-16T10:00:00+01:00",
        "arrival_city" => "Sevilla",
        "arrival_station" => "Santa Justa",
        "arrival_at" => "2026-02-16T14:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 2, result.length
  end

  test "filter: handles invalid date format gracefully" do
    segments = [
      {
        "departure_city" => "Madrid",
        "departure_station" => "Atocha",
        "departure_at" => "invalid-date",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 0, result.length
  end

  test "filter: handles nil values gracefully" do
    segments = [
      {
        "departure_city" => nil,
        "departure_station" => nil,
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_city" => "Barcelona",
        "arrival_station" => "Sants",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "fares" => [ { "name" => "Standard", "price_in_cents" => 5000, "currency" => "EUR" } ]
      }
    ]

    result = @filter.filter(segments)
    assert_equal 0, result.length
  end
end
