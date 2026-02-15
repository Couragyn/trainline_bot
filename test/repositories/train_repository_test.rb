require "test_helper"

class TrainRepositoryTest < ActiveSupport::TestCase
  def setup
    @repository = TrainRepository.new
    @departure_date = DateTime.new(2026, 2, 16, 9, 0, 0, "+01:00")
    Rails.cache.clear
  end

  def teardown
    Rails.cache.clear
  end

  test "find_segments: returns matching segments" do
    segments = @repository.find_segments("Madrid", "Barcelona", @departure_date)

    assert_kind_of Array, segments
    assert segments.any?

    segment = segments.first
    assert segment.key?("departure_station")
    assert segment.key?("departure_city")
    assert segment.key?("arrival_station")
    assert segment.key?("arrival_city")
  end

  test "find_segments: returns empty array for non-existent route" do
    segments = @repository.find_segments("Madrid", "NonExistentCity", @departure_date)

    assert_equal [], segments
  end

  test "find_segments: matches case-insensitively" do
    segments_lower = @repository.find_segments("madrid", "barcelona", @departure_date)

    segments_upper = @repository.find_segments("MADRID", "BARCELONA", @departure_date)

    assert_equal segments_lower.length, segments_upper.length
    assert segments_lower.any?
  end

  test "find_segments: matches by date only (ignores time)" do
    segments_morning = @repository.find_segments(
      "Madrid",
      "Barcelona",
      DateTime.new(2026, 2, 16, 6, 0, 0, "+01:00")
    )

    segments_evening = @repository.find_segments(
      "Madrid",
      "Barcelona",
      DateTime.new(2026, 2, 16, 23, 0, 0, "+01:00")
    )

    assert_equal segments_morning.length, segments_evening.length
  end

  test "find_segments: only returns segments with fares" do
    segments = @repository.find_segments("Madrid", "Barcelona", @departure_date)

    segments.each do |segment|
      fares = segment["fares"] || []
      assert fares.any?, "All segments should have fares"
    end
  end

  test "find_segments: matches departure city" do
    segments = @repository.find_segments("Madrid", "Barcelona", @departure_date)

    segments.each do |segment|
      normalized_city = LocationNormalizer.normalize(segment["departure_city"])
      normalized_query = LocationNormalizer.normalize("Madrid")

      assert_equal normalized_query, normalized_city
    end
  end

  test "find_segments: returns empty for invalid date" do
    invalid_date = DateTime.new(2026, 3, 25, 9, 0, 0, "+01:00")

    segments = @repository.find_segments("Madrid", "Barcelona", invalid_date)

    assert_equal [], segments
  end

  test "caching: uses Rails.cache for thread-safe data storage" do
    cache_key = TrainRepository::CACHE_KEY.call
    assert_nil Rails.cache.read(cache_key)

    @repository.find_segments("Madrid", "Barcelona", @departure_date)

    cached_data = Rails.cache.read(cache_key)
    assert_not_nil cached_data
    assert cached_data.key?("segments")
  end

  test "caching: second call uses cached data" do
    cache_key = TrainRepository::CACHE_KEY.call

    segments1 = @repository.find_segments("Madrid", "Barcelona", @departure_date)

    assert_not_nil Rails.cache.read(cache_key)

    segments2 = @repository.find_segments("Madrid", "Barcelona", @departure_date)

    assert_equal segments1.length, segments2.length
  end

  test "reload!: clears cache" do
    cache_key = TrainRepository::CACHE_KEY.call

    @repository.find_segments("Madrid", "Barcelona", @departure_date)

    assert_not_nil Rails.cache.read(cache_key)

    @repository.reload!

    assert_nil Rails.cache.read(cache_key)
  end

  test "caching: multiple repository instances share cache" do
    cache_key = TrainRepository::CACHE_KEY.call
    repo1 = TrainRepository.new
    repo2 = TrainRepository.new

    repo1.find_segments("Madrid", "Barcelona", @departure_date)

    cached_data_after_repo1 = Rails.cache.read(cache_key).dup
    assert_not_nil cached_data_after_repo1

    repo2.find_segments("Madrid", "Barcelona", @departure_date)

    # Cache should be unchanged - proves repo2 used cached data
    cached_data_after_repo2 = Rails.cache.read(cache_key)
    assert_equal cached_data_after_repo1, cached_data_after_repo2
  end

  test "pre-computed dates: segments have _parsed_date field" do
    cache_key = TrainRepository::CACHE_KEY.call
    Rails.cache.clear

    @repository.find_segments("Madrid", "Barcelona", @departure_date)

    cached_data = Rails.cache.read(cache_key)
    segments = cached_data["segments"]

    assert segments.any?, "Should have segments in cache"

    segments.each do |segment|
      assert segment.key?("_parsed_date"), "Each segment should have pre-computed _parsed_date"
      assert_kind_of Date, segment["_parsed_date"], "Pre-computed date should be a Date object"
    end
  end

  test "pre-computed dates: correctly parses ISO 8601 format" do
    cache_key = TrainRepository::CACHE_KEY.call
    Rails.cache.clear

    @repository.find_segments("Madrid", "Barcelona", @departure_date)

    cached_data = Rails.cache.read(cache_key)
    segments = cached_data["segments"]

    segments.each do |segment|
      departure_string = segment["departure_at"]
      expected_date = DateTime.iso8601(departure_string).to_date
      assert_equal expected_date, segment["_parsed_date"]
    end
  end
end
