class SegmentFilter
  def initialize(from:, to:, date:)
    @from = from
    @to = to
    @date = date
  end

  def filter(segments)
    segments.select { |segment| matches?(segment) }
  end

  private

  def matches?(segment)
    matches_route?(segment) &&
    matches_date?(segment) &&
    has_valid_fares?(segment)
  end

  def matches_route?(segment)
    departure_match = matches_location?(segment["departure_city"], @from) ||
                     matches_location?(segment["departure_station"], @from)
    
    arrival_match = matches_location?(segment["arrival_city"], @to) ||
                   matches_location?(segment["arrival_station"], @to)
    
    departure_match && arrival_match
  end

  def matches_location?(location, query)
    return false if location.nil? || query.nil?
    
    LocationNormalizer.normalize(location) == LocationNormalizer.normalize(query)
  end

  def matches_date?(segment)
    return false unless segment["departure_at"]
    
    segment_date = DateTime.parse(segment["departure_at"])
    segment_date.to_date == @date.to_date
  rescue ArgumentError
    false
  end

  def has_valid_fares?(segment)
    fares = segment["fares"] || []
    fares.is_a?(Array) && fares.any?
  end
end
