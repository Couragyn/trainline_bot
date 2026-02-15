require_relative "../lib/train_search/errors"

class TrainRepository
  FIXTURE_PATH = -> { TrainSearchConfig.fixture_data_path }
  CACHE_KEY = -> { "#{TrainSearchConfig.cache_key_prefix}/fixture_data" }
  CACHE_EXPIRES_IN = -> { TrainSearchConfig.cache_expiration }

  def initialize(logger: Rails.logger)
    @logger = logger
  end

  def find_segments(from:, to:, date:)    
    @logger.debug("TrainRepository#find_segments: #{from} → #{to} on #{date.to_date}")
    
    data = load_data
    segments = data["segments"] || []
    
    filter = SegmentFilter.new(from: from, to: to, date: date)
    filter.filter(segments)
  end

  def reload!
    cache_key = CACHE_KEY.call
    Rails.cache.delete(cache_key)
    @logger.info("TrainRepository#reload!: Cache cleared for #{cache_key}")
  end

  def healthy?
    File.exist?(FIXTURE_PATH.call) && load_data.is_a?(Hash)
  rescue StandardError => e
    @logger.error("TrainRepository#healthy?: Health check failed - #{e.message}")
    false
  end

  private

  def load_data
    cache_key = CACHE_KEY.call
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRES_IN.call) do
      @logger.info("TrainRepository#load_data: Loading train data from fixture into cache")
      read_fixture_data
    end
  end

  def read_fixture_data
    path = FIXTURE_PATH.call
    
    unless File.exist?(path)
      raise TrainSearch::DataSourceUnavailableError.new(
        "Train data file not found",
        context: { path: path }
      )
    end
    
    file_content = File.read(path)
    data = JSON.parse(file_content)
    
    @logger.info("TrainRepository#read_fixture_data: Loaded #{data['segments']&.length || 0} segments")
    
    data
  rescue JSON::ParserError => e
    raise TrainSearch::DataSourceUnavailableError.new(
      "Failed to parse train data JSON",
      context: { path: FIXTURE_PATH.call, error: e.message }
    )
  end
end

