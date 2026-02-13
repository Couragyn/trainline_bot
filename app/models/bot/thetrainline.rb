module Bot
  class Thetrainline
    FIXTURE_PATH = Rails.root.join('lib', 'fixtures', 'train_data.json')

    def self.find(from, to, departure_at)
      if Rails.env.production? && thetrainline_api_configured?
        search_thetrainline_api(from, to, departure_at)
      else
        search_fixture_data(from, to, departure_at)
      end
    end

    def self.validate_search_params(from, to, departure_at)
      errors = []
      
      errors << "Departure city or station is required" if from.blank?
      errors << "Arrival city or station is required" if to.blank?
      errors << "Departure date and time is required" if departure_at.blank?

      if departure_at.present?
        begin
          parsed_date = DateTime.parse(departure_at)
          min_date = DateTime.new(2026, 2, 16, 0, 0, 0, "+01:00")
          max_date = min_date + 365.days
          
          if parsed_date < min_date
            errors << "Departure date cannot be before February 16, 2026"
          elsif parsed_date > max_date
            errors << "Departure date cannot be more than one year in advance"
          end
        rescue ArgumentError
          errors << "Invalid date and time format"
        end
      end

      if from.present? && to.present? && from.downcase == to.downcase
        errors << "Departure and arrival locations must be different"
      end

      errors
    end

    def self.parse_departure_at(departure_at)
      return nil if departure_at.blank?
      DateTime.parse(departure_at)
    rescue ArgumentError
      nil
    end

    private

    # Will never be configured for this exercise
    def self.thetrainline_api_configured?
      false
    end

    def self.search_thetrainline_api(from, to, departure_at)
      []
    end

    def self.search_fixture_data(from, to, departure_at)
      data = load_fixture_data
      
      segments = find_segments(data, from, to, departure_at)
      
      format_segments(segments)
    end

    def self.load_fixture_data
      return @fixture_data if @fixture_data
      
      file_content = File.read(FIXTURE_PATH)
      @fixture_data = JSON.parse(file_content)
    end

    def self.find_segments(data, from, to, departure_at)
      segments = data['segments'] || []
      
      matching_segments = segments.select do |segment|
        matches_departure = segment['departure_city'].casecmp?(from) || segment['departure_station'].casecmp?(from)
        matches_arrival = segment['arrival_city'].casecmp?(to) || segment['arrival_station'].casecmp?(to)
        matches_departure && matches_arrival && same_date?(segment['departure_at'], departure_at)
      end
      
      matching_segments.sort_by do |segment|
        exact_departure = (segment['departure_city'] == from || segment['departure_station'] == from) ? 0 : 1
        exact_arrival = (segment['arrival_city'] == to || segment['arrival_station'] == to) ? 0 : 1
        [exact_departure, exact_arrival]
      end
    end

    def self.same_date?(segment_datetime, search_datetime)
      segment_date = DateTime.parse(segment_datetime)
      segment_date.to_date == search_datetime.to_date
    rescue ArgumentError
      false
    end

    def self.format_segments(segments)
      segments.map do |segment|
        {
          departure_station: segment['departure_station'],
          departure_city: segment['departure_city'],
          departure_at: DateTime.parse(segment['departure_at']),
          arrival_station: segment['arrival_station'],
          arrival_city: segment['arrival_city'],
          arrival_at: DateTime.parse(segment['arrival_at']),
          service_agencies: segment['service_agencies'] || [],
          duration_in_minutes: segment['duration_in_minutes'],
          changeovers: segment['changeovers'] || 0,
          products: segment['products'] || [],
          fares: format_fares(segment['fares'] || [])
        }
      end
    end

    def self.format_fares(fares)
      fares.map do |fare|
        {
          name: fare['name'],
          price_in_cents: fare['price_in_cents'],
          currency: fare['currency']
        }
      end
    end
  end
end
