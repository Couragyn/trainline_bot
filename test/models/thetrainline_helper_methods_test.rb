require "test_helper"

class ThetrainlineHelperMethodsTest < ActiveSupport::TestCase
  # Test the normalize method

  test "normalize: converts to lowercase" do
    result = Bot::Thetrainline.send(:normalize, "MADRID")
    assert_equal "madrid", result
  end

  test "normalize: removes accents" do
    result = Bot::Thetrainline.send(:normalize, "São Paulo")
    assert_equal "sao paulo", result
  end

  test "normalize: removes multiple types of accents" do
    result = Bot::Thetrainline.send(:normalize, "Montpellier")
    assert_equal "montpellier", result
  end

  test "normalize: removes apostrophes" do
    result = Bot::Thetrainline.send(:normalize, "O'Neill")
    assert_equal "oneill", result
  end

  test "normalize: removes various apostrophe types" do
    result = Bot::Thetrainline.send(:normalize, "L'Aquila")
    assert_equal "laquila", result
  end

  test "normalize: strips leading and trailing whitespace" do
    result = Bot::Thetrainline.send(:normalize, "  Madrid  ")
    assert_equal "madrid", result
  end

  test "normalize: handles nil gracefully" do
    result = Bot::Thetrainline.send(:normalize, nil)
    assert_equal "", result
  end

  test "normalize: handles empty string" do
    result = Bot::Thetrainline.send(:normalize, "")
    assert_equal "", result
  end

  test "normalize: combines all transformations" do
    result = Bot::Thetrainline.send(:normalize, "  São Paulo  ")
    assert_equal "sao paulo", result
  end

  # Test the matches_location? method

  test "matches_location?: matches city name exactly when normalized" do
    segment = { "departure_city" => "Madrid", "departure_station" => "Atocha" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "madrid")
    assert result
  end

  test "matches_location?: matches station name exactly when normalized" do
    segment = { "departure_city" => "Madrid", "departure_station" => "Atocha" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "atocha")
    assert result
  end

  test "matches_location?: matches with different case" do
    segment = { "arrival_city" => "Barcelona", "arrival_station" => "Sants" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "arrival", "BARCELONA")
    assert result
  end

  test "matches_location?: matches with accents in query" do
    segment = { "departure_city" => "Sao Paulo", "departure_station" => "Central" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "São Paulo")
    assert result
  end

  test "matches_location?: matches with accents in segment" do
    segment = { "arrival_city" => "São Paulo", "arrival_station" => "Central" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "arrival", "Sao Paulo")
    assert result
  end

  test "matches_location?: does not match city when query is wrong" do
    segment = { "departure_city" => "Madrid", "departure_station" => "Atocha" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "barcelona")
    refute result
  end

  test "matches_location?: does not match station when query is wrong" do
    segment = { "departure_city" => "Madrid", "departure_station" => "Atocha" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "sants")
    refute result
  end

  test "matches_location?: matches arrival city" do
    segment = { "arrival_city" => "Lyon", "arrival_station" => "Perrache" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "arrival", "lyon")
    assert result
  end

  test "matches_location?: matches with apostrophes normalized" do
    segment = { "departure_city" => "L'Aquila", "departure_station" => "Station" }
    result = Bot::Thetrainline.send(:matches_location?, segment, "departure", "Laquila")
    assert result
  end

  # Test the same_date? method

  test "same_date?: returns true for same day" do
    segment_datetime = "2026-02-16T09:00:00+01:00"
    search_datetime = DateTime.new(2026, 2, 16, 14, 30, 0, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    assert result
  end

  test "same_date?: returns false for different days" do
    segment_datetime = "2026-02-16T09:00:00+01:00"
    search_datetime = DateTime.new(2026, 2, 17, 9, 0, 0, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    refute result
  end

  test "same_date?: returns false for different months" do
    segment_datetime = "2026-02-16T09:00:00+01:00"
    search_datetime = DateTime.new(2026, 3, 16, 9, 0, 0, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    refute result
  end

  test "same_date?: returns false for different years" do
    segment_datetime = "2026-02-16T09:00:00+01:00"
    search_datetime = DateTime.new(2025, 2, 16, 9, 0, 0, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    refute result
  end

  test "same_date?: handles invalid date format gracefully" do
    segment_datetime = "invalid-date"
    search_datetime = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    refute result
  end

  test "same_date?: ignores time and only compares dates" do
    segment_datetime = "2026-02-16T23:59:59+01:00"
    search_datetime = DateTime.new(2026, 2, 16, 0, 0, 1, "+01:00")
    result = Bot::Thetrainline.send(:same_date?, segment_datetime, search_datetime)
    assert result
  end

  # Test the parse_departure_at method

  test "parse_departure_at: parses valid datetime string" do
    result = Bot::Thetrainline.parse_departure_at("2026-02-16T09:00:00+01:00")
    assert_instance_of DateTime, result
    assert_equal 2026, result.year
    assert_equal 2, result.month
    assert_equal 16, result.day
    assert_equal 9, result.hour
  end

  test "parse_departure_at: returns nil for blank string" do
    result = Bot::Thetrainline.parse_departure_at("")
    assert_nil result
  end

  test "parse_departure_at: returns nil for nil" do
    result = Bot::Thetrainline.parse_departure_at(nil)
    assert_nil result
  end

  test "parse_departure_at: returns nil for invalid date format" do
    result = Bot::Thetrainline.parse_departure_at("not-a-date")
    assert_nil result
  end

  test "parse_departure_at: parses various datetime formats" do
    result = Bot::Thetrainline.parse_departure_at("2026-02-16 09:00:00")
    assert_instance_of DateTime, result
  end

  # Test the validate_search_params method

  test "validate_search_params: accepts valid search parameters" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2026-02-16T09:00:00+01:00")
    assert_empty errors
  end

  test "validate_search_params: rejects blank from location" do
    errors = Bot::Thetrainline.validate_search_params("", "Barcelona", "2026-02-16T09:00:00+01:00")
    assert_includes errors, "Departure city or station is required"
  end

  test "validate_search_params: rejects blank to location" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "", "2026-02-16T09:00:00+01:00")
    assert_includes errors, "Arrival city or station is required"
  end

  test "validate_search_params: rejects blank departure date" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "")
    assert_includes errors, "Departure date and time is required"
  end

  test "validate_search_params: rejects date before minimum allowed date" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2026-02-15T09:00:00+01:00")
    assert_includes errors, "Departure date cannot be before February 16, 2026"
  end

  test "validate_search_params: rejects date more than one year in advance" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2027-02-17T09:00:00+01:00")
    assert_includes errors, "Departure date cannot be more than one year in advance"
  end

  test "validate_search_params: rejects invalid date format" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "not-a-date")
    assert_includes errors, "Invalid date and time format"
  end

  test "validate_search_params: rejects same from and to location" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "madrid", "2026-02-16T09:00:00+01:00")
    assert_includes errors, "Departure and arrival locations must be different"
  end

  test "validate_search_params: rejects same location with different case as error" do
    errors = Bot::Thetrainline.validate_search_params("MADRID", "madrid", "2026-02-16T09:00:00+01:00")
    assert_includes errors, "Departure and arrival locations must be different"
  end

  test "validate_search_params: accepts date exactly at minimum allowed date" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2026-02-16T00:00:00+01:00")
    assert_empty errors
  end

  test "validate_search_params: accepts date exactly at maximum allowed date" do
    errors = Bot::Thetrainline.validate_search_params("Madrid", "Barcelona", "2027-02-16T00:00:00+01:00")
    assert_empty errors
  end

  # Test the format_segments method

  test "format_segments: formats segments with all required fields" do
    segments = [
      {
        "departure_station" => "Atocha",
        "departure_city" => "Madrid",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_station" => "Sants",
        "arrival_city" => "Barcelona",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "service_agencies" => [ "Renfe" ],
        "duration_in_minutes" => 240,
        "changeovers" => 0,
        "products" => [ "AVE" ],
        "fares" => [
          {
            "name" => "Standard",
            "price_in_cents" => 5000,
            "currency" => "EUR"
          }
        ]
      }
    ]

    result = Bot::Thetrainline.send(:format_segments, segments)

    assert_equal 1, result.length
    formatted = result.first

    assert_equal "Atocha", formatted[:departure_station]
    assert_equal "Madrid", formatted[:departure_city]
    assert_kind_of DateTime, formatted[:departure_at]
    assert_equal "Sants", formatted[:arrival_station]
    assert_equal "Barcelona", formatted[:arrival_city]
    assert_kind_of DateTime, formatted[:arrival_at]
    assert_equal [ "Renfe" ], formatted[:service_agencies]
    assert_equal 240, formatted[:duration_in_minutes]
    assert_equal 0, formatted[:changeovers]
    assert_equal [ "AVE" ], formatted[:products]
    assert_equal 1, formatted[:fares].length
  end

  test "format_segments: formats segments with empty optional fields" do
    segments = [
      {
        "departure_station" => "Central",
        "departure_city" => "Paris",
        "departure_at" => "2026-02-16T10:00:00+01:00",
        "arrival_station" => "Gare",
        "arrival_city" => "Lyon",
        "arrival_at" => "2026-02-16T12:00:00+01:00",
        "duration_in_minutes" => 120,
        "fares" => []
      }
    ]

    result = Bot::Thetrainline.send(:format_segments, segments)

    assert_equal 1, result.length
    formatted = result.first

    assert_equal [], formatted[:service_agencies]
    assert_equal 0, formatted[:changeovers]
    assert_equal [], formatted[:products]
    assert_equal [], formatted[:fares]
  end

  test "format_segments: formats multiple segments" do
    segments = [
      {
        "departure_station" => "Atocha",
        "departure_city" => "Madrid",
        "departure_at" => "2026-02-16T09:00:00+01:00",
        "arrival_station" => "Sants",
        "arrival_city" => "Barcelona",
        "arrival_at" => "2026-02-16T13:00:00+01:00",
        "service_agencies" => [],
        "duration_in_minutes" => 240,
        "changeovers" => 0,
        "products" => [],
        "fares" => []
      },
      {
        "departure_station" => "Atocha",
        "departure_city" => "Madrid",
        "departure_at" => "2026-02-16T14:00:00+01:00",
        "arrival_station" => "Sants",
        "arrival_city" => "Barcelona",
        "arrival_at" => "2026-02-16T18:00:00+01:00",
        "service_agencies" => [],
        "duration_in_minutes" => 240,
        "changeovers" => 0,
        "products" => [],
        "fares" => []
      }
    ]

    result = Bot::Thetrainline.send(:format_segments, segments)
    assert_equal 2, result.length
  end

  # Test the format_fares method

  test "format_fares: formats fares correctly" do
    fares = [
      {
        "name" => "Economy",
        "price_in_cents" => 3000,
        "currency" => "EUR"
      },
      {
        "name" => "Business",
        "price_in_cents" => 8000,
        "currency" => "EUR"
      }
    ]

    result = Bot::Thetrainline.send(:format_fares, fares)

    assert_equal 2, result.length
    assert_equal "Economy", result[0][:name]
    assert_equal 3000, result[0][:price_in_cents]
    assert_equal "EUR", result[0][:currency]
    assert_equal "Business", result[1][:name]
    assert_equal 8000, result[1][:price_in_cents]
  end

  test "format_fares: handles empty fares array" do
    fares = []
    result = Bot::Thetrainline.send(:format_fares, fares)
    assert_equal [], result
  end

  test "format_fares: formats single fare" do
    fares = [
      {
        "name" => "Standard",
        "price_in_cents" => 5500,
        "currency" => "EUR"
      }
    ]

    result = Bot::Thetrainline.send(:format_fares, fares)
    assert_equal 1, result.length
    assert_equal "Standard", result[0][:name]
    assert_equal 5500, result[0][:price_in_cents]
  end
end
