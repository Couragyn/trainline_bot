require_relative "../lib/train_search/errors"

class TrainRepository
  FIXTURE_PATH = -> { TrainSearchConfig.fixture_data_path }
  CACHE_KEY = -> { "#{TrainSearchConfig.cache_key_prefix}/fixture_data" }
  CACHE_EXPIRES_IN = -> { TrainSearchConfig.cache_expiration }

  def initialize(logger = Rails.logger)
    @logger = logger
  end

  # Finds train segments matching the search criteria.
  # Filters segments by departure/arrival locations and departure date.
  # @param from [String] departure city or station name
  # @param to [String] arrival city or station name
  # @param date [DateTime] departure date (time is ignored, only date matters)
  # @return [Array<Hash>] array of segment hashes with departure/arrival info and fares
  # @raise [TrainSearch::DataSourceUnavailableError] if fixture data is missing or invalid
  def find_segments(from, to, date)
    @logger.debug("TrainRepository#find_segments: #{from} → #{to} on #{date.to_date}")

    data = load_data
    segments = data["segments"] || []

    filter = SegmentFilter.new(from, to, date)
    filter.filter(segments)
  end

  # Clears the cached train data, forcing next request to reload from fixture.
  # @return [Boolean] result of cache delete operation
  def reload!
    cache_key = CACHE_KEY.call
    Rails.cache.delete(cache_key)
    @logger.info("TrainRepository#reload!: Cache cleared for #{cache_key}")
  end

  # Checks if the repository can successfully load train data.
  # @return [Boolean] true if fixture file exists and can be loaded, false otherwise
  # @raise [StandardError] if health check fails
  def healthy?
    File.exist?(FIXTURE_PATH.call) && load_data.is_a?(Hash)
  rescue StandardError => e
    @logger.error("TrainRepository#healthy?: Health check failed - #{e.message}")
    false
  end

  private

  def load_data
    cache_key = CACHE_KEY.call

    begin
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRES_IN.call) do
        @logger.info("TrainRepository#load_data: Loading train data from fixture into cache")
        read_fixture_data
      end
    rescue StandardError => e
      @logger.warn("TrainRepository#load_data: Cache operation failed, falling back to direct read - #{e.message}")
      read_fixture_data
    end
  end

  def read_fixture_data
    path = FIXTURE_PATH.call

    unless File.exist?(path)
      raise TrainSearch::DataSourceUnavailableError.new(
        "Train data file not found",
        { path: path }
      )
    end

    file_content = File.read(path)
    data = JSON.parse(file_content)

    @logger.info("TrainRepository#read_fixture_data: Loaded #{data['segments']&.length || 0} segments")

    data
  rescue JSON::ParserError => e
    raise TrainSearch::DataSourceUnavailableError.new(
      "Failed to parse train data JSON",
      { path: FIXTURE_PATH.call, error: e.message }
    )
  end
end
