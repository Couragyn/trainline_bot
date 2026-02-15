class TrainSearchValidator
  MIN_DATE = DateTime.new(2026, 2, 16, 0, 0, 0, "+01:00")
  MAX_DATE = DateTime.new(2027, 2, 22, 0, 0, 0, "+01:00")

  attr_reader :errors

  def initialize(from:, to:, departure_at:)
    @from = from
    @to = to
    @departure_at = departure_at
    @errors = []
  end

  def valid?
    @errors = []
    
    validate_presence
    validate_departure_date
    validate_different_locations
    
    @errors.empty?
  end

  def self.parse_departure_at(departure_at)
    return nil if departure_at.blank?
    DateTime.parse(departure_at)
  rescue ArgumentError
    nil
  end

  private

  def validate_presence
    @errors << "Departure city or station is required" if @from.blank?
    @errors << "Arrival city or station is required" if @to.blank?
    @errors << "Departure date and time is required" if @departure_at.blank?
  end

  def validate_departure_date
    return if @departure_at.blank?

    begin
      parsed_date = DateTime.parse(@departure_at)
      
      if parsed_date < MIN_DATE
        @errors << "Departure date cannot be before February 16, 2026"
      elsif parsed_date > MAX_DATE
        @errors << "Departure date cannot be after February 22, 2027"
      end
    rescue ArgumentError
      @errors << "Invalid date and time format"
    end
  end

  def validate_different_locations
    return if @from.blank? || @to.blank?
    
    if LocationNormalizer.normalize(@from) == LocationNormalizer.normalize(@to)
      @errors << "Departure and arrival locations must be different"
    end
  end
end
