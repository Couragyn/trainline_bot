class LocationNormalizer
  class << self
    # Normalizes location strings for case-insensitive comparison.
    # Removes accents, apostrophes, and converts to lowercase.
    # @param string [String, nil] location name to normalize
    # @return [String] normalized location string (empty string if nil)
    def normalize(string)
      return "" if string.nil?

      string.unicode_normalize(:nfd)
            .gsub(/[\u0300-\u036f]/, "")
            .gsub(/['''`]/, "")
            .downcase
            .strip
    end
  end
end
