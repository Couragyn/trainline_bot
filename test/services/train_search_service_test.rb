require "test_helper"

class TrainSearchServiceTest < ActiveSupport::TestCase
  def setup
    @service = TrainSearchService.new
    @departure_date = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
  end

  test "search: returns formatted segments" do
    results = @service.search(
      from: "Madrid",
      to: "Barcelona",
      departure_at: @departure_date
    )

    assert_kind_of Array, results
    assert results.any?

    result = results.first
    assert result.key?(:departure_station)
    assert result.key?(:departure_city)
    assert result.key?(:departure_at)
    assert result.key?(:arrival_station)
    assert result.key?(:arrival_city)
    assert result.key?(:arrival_at)
    assert result.key?(:service_agencies)
    assert result.key?(:duration_in_minutes)
    assert result.key?(:changeovers)
    assert result.key?(:products)
    assert result.key?(:fares)
  end

  test "search: returns segments sorted by departure time" do
    results = @service.search(
      from: "Madrid",
      to: "Barcelona",
      departure_at: @departure_date
    )

    assert results.any?

    results.each_cons(2) do |segment1, segment2|
      assert_operator segment1[:departure_at], :<=, segment2[:departure_at]
    end
  end

  test "search: formats fares correctly" do
    results = @service.search(
      from: "Madrid",
      to: "Barcelona",
      departure_at: @departure_date
    )

    result = results.first
    fare = result[:fares].first

    assert fare.key?(:name)
    assert fare.key?(:price_in_cents)
    assert fare.key?(:currency)
    assert_kind_of String, fare[:name]
    assert_kind_of Integer, fare[:price_in_cents]
    assert_kind_of String, fare[:currency]
  end

  test "search: returns empty array for non-existent route" do
    results = @service.search(
      from: "Madrid",
      to: "NonExistentCity",
      departure_at: @departure_date
    )

    assert_equal [], results
  end

  test "search: handles case-insensitive searches" do
    results_lower = @service.search(
      from: "madrid",
      to: "barcelona",
      departure_at: @departure_date
    )

    results_upper = @service.search(
      from: "MADRID",
      to: "BARCELONA",
      departure_at: @departure_date
    )

    assert_equal results_lower.length, results_upper.length
  end
end
