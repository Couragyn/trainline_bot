require "test_helper"

class FixtureValidationTest < ActiveSupport::TestCase
  def setup
    @fixture_path = Rails.root.join('lib', 'fixtures', 'train_data.json')
    @raw_fixture = JSON.parse(File.read(@fixture_path))
  end

  test "fixture file exists" do
    assert File.exist?(@fixture_path), "Fixture file should exist at #{@fixture_path}"
  end

  test "fixture file is valid JSON" do
    begin
      parsed = JSON.parse(File.read(@fixture_path))
      assert parsed.present?, "JSON should parse to a non-empty object"
    rescue JSON::ParserError => e
      flunk("Fixture file should be valid JSON: #{e.message}")
    end
  end

  test "fixture has segments key" do
    assert @raw_fixture.key?('segments'), "Fixture should have 'segments' key"
  end

  test "fixture segments is an array" do
    assert_kind_of Array, @raw_fixture['segments']
  end

  test "fixture segments is not empty" do
    assert_operator @raw_fixture['segments'].length, :>, 0, "Fixture should have at least one segment"
  end

  test "each segment has all required fields" do
    required_fields = [
      'departure_station', 'departure_city', 'departure_at',
      'arrival_station', 'arrival_city', 'arrival_at',
      'service_agencies', 'duration_in_minutes', 'changeovers',
      'products', 'fares'
    ]
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      required_fields.each do |field|
        assert segment.key?(field), "Segment #{index} missing field: #{field}"
      end
    end
  end

  test "each segment has correct field types" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_kind_of String, segment['departure_station'], "Segment #{index}: departure_station should be String"
      assert_kind_of String, segment['departure_city'], "Segment #{index}: departure_city should be String"
      assert_kind_of String, segment['departure_at'], "Segment #{index}: departure_at should be String (ISO format)"
      assert_kind_of String, segment['arrival_station'], "Segment #{index}: arrival_station should be String"
      assert_kind_of String, segment['arrival_city'], "Segment #{index}: arrival_city should be String"
      assert_kind_of String, segment['arrival_at'], "Segment #{index}: arrival_at should be String (ISO format)"
      assert_kind_of Array, segment['service_agencies'], "Segment #{index}: service_agencies should be Array"
      assert_kind_of Integer, segment['duration_in_minutes'], "Segment #{index}: duration_in_minutes should be Integer"
      assert_kind_of Integer, segment['changeovers'], "Segment #{index}: changeovers should be Integer"
      assert_kind_of Array, segment['products'], "Segment #{index}: products should be Array"
      assert_kind_of Array, segment['fares'], "Segment #{index}: fares should be Array"
    end
  end

  test "all departure_at times are valid ISO 8601 format" do
    result_count = 0
    @raw_fixture['segments'].each_with_index do |segment, index|
      begin
        DateTime.iso8601(segment['departure_at'])
        result_count += 1
      rescue ArgumentError => e
        flunk("Segment #{index} departure_at should be valid ISO 8601: #{e.message}")
      end
    end
    assert_operator result_count, :>, 0, "Should have validated at least one segment"
  end

  test "all arrival_at times are valid ISO 8601 format" do
    result_count = 0
    @raw_fixture['segments'].each_with_index do |segment, index|
      begin
        DateTime.iso8601(segment['arrival_at'])
        result_count += 1
      rescue ArgumentError => e
        flunk("Segment #{index} arrival_at should be valid ISO 8601: #{e.message}")
      end
    end
    assert_operator result_count, :>, 0, "Should have validated at least one segment"
  end

  test "arrival times are after departure times" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      departure = DateTime.iso8601(segment['departure_at'])
      arrival = DateTime.iso8601(segment['arrival_at'])
      
      assert_operator arrival, :>, departure, "Segment #{index}: arrival should be after departure"
    end
  end

  test "duration in minutes matches time difference" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      departure = DateTime.iso8601(segment['departure_at'])
      arrival = DateTime.iso8601(segment['arrival_at'])
      
      time_diff_days = (arrival - departure)
      expected_duration = (time_diff_days.to_f * 24 * 60).to_i
      
      assert_in_delta segment['duration_in_minutes'], expected_duration, 1,
        "Segment #{index}: duration should match time difference"
    end
  end

  test "departure dates are within reasonable range" do
    min_date = DateTime.new(2026, 2, 16)
    max_date = DateTime.new(2027, 2, 12)
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      departure = DateTime.iso8601(segment['departure_at'])
      
      assert_operator departure, :>=, min_date, "Segment #{index}: departure should be after Feb 16, 2026"
      assert_operator departure, :<=, max_date, "Segment #{index}: departure should be before Feb 12, 2027"
    end
  end

  test "service_agencies array is not empty" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_operator segment['service_agencies'].length, :>, 0, 
        "Segment #{index}: should have at least one service agency"
    end
  end

  test "service_agencies contains only known values" do
    valid_agencies = ['thetrainline', 'renfe', 'sncf', 'db', 'trenitalia']
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['service_agencies'].each do |agency|
        assert valid_agencies.include?(agency.downcase), 
          "Segment #{index}: unknown agency '#{agency}'"
      end
    end
  end

  test "products array is not empty" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_operator segment['products'].length, :>, 0, 
        "Segment #{index}: should have at least one product"
    end
  end

  test "products contains only known values" do
    valid_products = ['train', 'bus', 'coach', 'flight', 'ferry']
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['products'].each do |product|
        assert valid_products.include?(product.downcase), 
          "Segment #{index}: unknown product '#{product}'"
      end
    end
  end

  test "changeovers is non-negative" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_operator segment['changeovers'], :>=, 0, 
        "Segment #{index}: changeovers should be >= 0"
    end
  end

  test "changeovers is reasonable number" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_operator segment['changeovers'], :<, 10, 
        "Segment #{index}: changeovers should be < 10 (unreasonable value)"
    end
  end

  test "each segment has at least one fare" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_operator segment['fares'].length, :>, 0, 
        "Segment #{index}: should have at least one fare"
    end
  end

  test "each fare has required fields" do
    required_fare_fields = ['name', 'price_in_cents', 'currency']
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        required_fare_fields.each do |field|
          assert fare.key?(field), 
            "Segment #{index}, Fare #{fare_idx} missing field: #{field}"
        end
      end
    end
  end

  test "each fare has correct field types" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        assert_kind_of String, fare['name'], 
          "Segment #{index}, Fare #{fare_idx}: name should be String"
        assert_kind_of Integer, fare['price_in_cents'], 
          "Segment #{index}, Fare #{fare_idx}: price_in_cents should be Integer"
        assert_kind_of String, fare['currency'], 
          "Segment #{index}, Fare #{fare_idx}: currency should be String"
      end
    end
  end

  test "fare prices are positive" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        assert_operator fare['price_in_cents'], :>, 0, 
          "Segment #{index}, Fare #{fare_idx}: price should be > 0"
      end
    end
  end

  test "fare prices are reasonable (less than 100,000 EUR cents / 1000 EUR)" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        assert_operator fare['price_in_cents'], :<, 100000, 
          "Segment #{index}, Fare #{fare_idx}: price seems unreasonably high"
      end
    end
  end

  test "currency is valid ISO 4217 code" do
    valid_currencies = ['EUR', 'GBP', 'USD', 'CHF', 'SEK', 'NOK']
    
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        assert valid_currencies.include?(fare['currency']), 
          "Segment #{index}, Fare #{fare_idx}: unknown currency '#{fare['currency']}'"
      end
    end
  end

  test "all fares for a segment use same currency" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      currencies = segment['fares'].map { |f| f['currency'] }.uniq
      
      assert_equal currencies.length, 1, 
        "Segment #{index}: all fares should use the same currency"
    end
  end

  test "no duplicate segments" do
    segments = @raw_fixture['segments']
    
    segment_ids = segments.map do |s|
      [s['departure_station'], s['arrival_station'], s['departure_at']].join('|')
    end
    
    duplicates = segment_ids.select { |id| segment_ids.count(id) > 1 }.uniq
    assert duplicates.empty?, "Found duplicate segments: #{duplicates.join(', ')}"
  end

  test "station names are not empty" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert segment['departure_station'].present?, 
        "Segment #{index}: departure_station should not be empty"
      assert segment['arrival_station'].present?, 
        "Segment #{index}: arrival_station should not be empty"
      assert segment['departure_city'].present?, 
        "Segment #{index}: departure_city should not be empty"
      assert segment['arrival_city'].present?, 
        "Segment #{index}: arrival_city should not be empty"
    end
  end

  test "no self-loops (departure = arrival)" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      assert_not_equal segment['departure_station'], segment['arrival_station'], 
        "Segment #{index}: should not depart and arrive at same station"
    end
  end

  test "fare names are descriptive and not empty" do
    @raw_fixture['segments'].each_with_index do |segment, index|
      segment['fares'].each_with_index do |fare, fare_idx|
        assert fare['name'].present?, 
          "Segment #{index}, Fare #{fare_idx}: name should not be empty"
        assert fare['name'].length > 3, 
          "Segment #{index}, Fare #{fare_idx}: name seems too short"
      end
    end
  end

  test "fixture provides multiple routes" do
    routes = @raw_fixture['segments'].map do |s|
      "#{s['departure_city']}→#{s['arrival_city']}"
    end.uniq
    
    assert_operator routes.length, :>, 1, "Fixture should have multiple routes"
  end

  test "fixture provides multiple departure times per route" do
    by_route = @raw_fixture['segments'].group_by do |s|
      "#{s['departure_city']}→#{s['arrival_city']}"
    end
    
    has_multiple = by_route.any? { |route, segments| segments.length > 1 }
    assert has_multiple, "At least one route should have multiple departure times"
  end
end
