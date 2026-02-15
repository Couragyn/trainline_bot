module Bot
  class Thetrainline
    def self.find(from, to, departure_at)
      service = TrainSearchService.new
      service.search(from: from, to: to, departure_at: departure_at)
    end

    def self.validate_search_params(from, to, departure_at)
      validator = TrainSearchValidator.new(
        from: from,
        to: to,
        departure_at: departure_at
      )
      validator.valid?
      validator.errors
    end

    def self.parse_departure_at(departure_at)
      TrainSearchValidator.parse_departure_at(departure_at)
    end
  end
end
