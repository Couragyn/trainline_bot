class LocationNormalizer
  class << self
    def normalize(string)
      return "" if string.nil?
      
      string.unicode_normalize(:nfd)
            .gsub(/[\u0300-\u036f]/, "")  # Remove accent marks
            .gsub(/['''`]/, "")            # Remove apostrophes/quotes
            .downcase
            .strip
    end
  end
end
