class SegmentFilter
  def initialize(from, to, date)
    @from = from
    @to = to
    @date = date

    # Pre-compute normalized locations to avoid repeated normalization per segment
    @from_normalized = LocationNormalizer.normalize(@from)
    @to_normalized = LocationNormalizer.normalize(@to)

    # Pre-compute target date to avoid repeated DateTime.parse() calls
    @target_date = if date.is_a?(DateTime)
      date.to_date
    else
      DateTime.parse(date).to_date
    end
  rescue ArgumentError
    @target_date = nil
  end

  # Filters segments to only those matching the search criteria.
  # @param segments [Array<Hash>] array of segment hashes from fixture data
  # @return [Array<Hash>] filtered segments matching search criteria
  def filter(segments)
    return [] if @target_date.nil?

    segments.select { |segment| matches?(segment) }
  end

  private

  def matches?(segment)
    matches_route?(segment) &&
      matches_date?(segment) &&
      has_valid_fares?(segment)
  end

  def matches_route?(segment)
    departure_match = matches_location?(segment["departure_city"], @from_normalized) ||
                      matches_location?(segment["departure_station"], @from_normalized)

    arrival_match = matches_location?(segment["arrival_city"], @to_normalized) ||
                    matches_location?(segment["arrival_station"], @to_normalized)

    departure_match && arrival_match
  end

  def matches_location?(location, normalized_query)
    return false if location.nil?

    LocationNormalizer.normalize(location) == normalized_query
  end

  def matches_date?(segment)
    return false unless segment["departure_at"]

    segment_date = segment["_parsed_date"]
    segment_date ||= DateTime.parse(segment["departure_at"]).to_date

    segment_date == @target_date
  rescue ArgumentError
    false
  end

  def has_valid_fares?(segment)
    fares = segment["fares"] || []
    fares.is_a?(Array) && fares.any?
  end
end
