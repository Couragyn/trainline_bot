module Bot
  class Thetrainline
    # Finds train journeys between two locations on a specific date.
    # @param from [String] departure city or station name
    # @param to [String] arrival city or station name
    # @param departure_at [DateTime] departure date and time
    # @param service [TrainSearchService] optional service instance for dependency injection
    # @return [Array<Hash>] array of journey segments with departure info, arrival info, and fares
    # @raise [TrainSearch::DataSourceUnavailableError] if data cannot be loaded
    def self.find(from, to, departure_at, service = nil)
      service ||= TrainSearchService.new(TrainRepository.new, Rails.logger)
      service.search(from, to, departure_at)
    end

    # Validates search parameters and returns any validation errors.
    # @param from [String] departure city or station name
    # @param to [String] arrival city or station name
    # @param departure_at [String, DateTime] departure date/time string or DateTime object
    # @return [Array<String>] array of validation error messages (empty if valid)
    def self.validate_search_params(from, to, departure_at)
      validator = TrainSearchValidator.new(from, to, departure_at)
      validator.valid?
      validator.errors
    end

    # Parses a departure date string into a DateTime object.
    # @param departure_at [String] date string to parse
    # @return [DateTime, nil] parsed DateTime or nil if invalid
    def self.parse_departure_at(departure_at)
      TrainSearchValidator.parse_departure_at(departure_at)
    end
  end
end
