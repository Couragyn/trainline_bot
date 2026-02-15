class TrainSearchService
  def initialize(repository = TrainRepository.new, logger = Rails.logger)
    @repository = repository
    @logger = logger
  end

  # Searches for train journeys between two locations on a specific date.
  # @param from [String] departure city or station name
  # @param to [String] arrival city or station name
  # @param departure_at [DateTime] departure date and time
  # @return [Array<Hash>] array of journey segments with symbolized keys and formatted data
  # @raise [TrainSearch::DataSourceUnavailableError] if data cannot be loaded
  def search(from, to, departure_at)
    @logger.debug("TrainSearchService#search: #{from} to #{to} at #{departure_at}")

    segments = @repository.find_segments(from, to, departure_at)

    formatted_segments = format_segments(segments)
    sorted_segments = sort_by_departure_time(formatted_segments)
    limited_results = limit_results(sorted_segments)

    @logger.info("TrainSearchService#search: Returning #{limited_results.length} segments")

    limited_results
  end

  private

  def format_segments(segments)
    segments.map do |segment|
      {
        departure_station: segment["departure_station"],
        departure_city: segment["departure_city"],
        departure_at: DateTime.parse(segment["departure_at"]),
        arrival_station: segment["arrival_station"],
        arrival_city: segment["arrival_city"],
        arrival_at: DateTime.parse(segment["arrival_at"]),
        service_agencies: segment["service_agencies"] || [],
        duration_in_minutes: segment["duration_in_minutes"],
        changeovers: segment["changeovers"] || 0,
        products: segment["products"] || [],
        fares: format_fares(segment["fares"] || [])
      }
    end
  end

  def format_fares(fares)
    fares.map do |fare|
      {
        name: fare["name"],
        price_in_cents: fare["price_in_cents"],
        currency: fare["currency"]
      }
    end
  end

  def sort_by_departure_time(segments)
    segments.sort_by { |segment| segment[:departure_at] }
  end

  def limit_results(segments)
    max_results = TrainSearchConfig.max_results

    if segments.length > max_results
      @logger.warn("TrainSearchService#limit_results: Limiting #{segments.length} results to #{max_results}")
      segments.take(max_results)
    else
      segments
    end
  end
end
