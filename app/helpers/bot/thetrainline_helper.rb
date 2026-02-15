module Bot::ThetrainlineHelper
  # Formats a DateTime into a 24-hour time string.
  # @param datetime [DateTime]
  # @return [String]
  def format_time(datetime)
    datetime.strftime("%H:%M")
  end

  # Formats a duration in minutes (e.g., "2h 30m").
  # @param minutes [Integer]
  # @return [String]
  def format_duration(minutes)
    hours = minutes / 60
    mins = minutes % 60
    "#{hours}h #{mins}m"
  end

  # Formats a DateTime into a friendly date/time string.
  # @param datetime [DateTime]
  # @return [String]
  def format_datetime(datetime)
    datetime.strftime("%B %d, %Y at %H:%M")
  end

  # Formats a list of agencies into a display string.
  # @param agencies [Array<String>]
  # @return [String]
  def format_operators(agencies)
    agencies.map(&:titleize).join(", ")
  end

  # Formats a price in cents with a currency symbol.
  # @param price_in_cents [Integer, nil]
  # @param currency [String, nil]
  # @return [String]
  def format_price(price_in_cents, currency)
    return "N/A" if price_in_cents.nil?

    symbol = currency_symbol(currency)
    amount = (price_in_cents / 100.0).round(2)
    "#{symbol}#{format('%.2f', amount)}"
  end

  # Formats the cheapest fare price from a list of fares.
  # @param fares [Array<Hash>]
  # @return [String]
  def format_cheapest_price(fares)
    fare = fares.min_by { |f| f[:price_in_cents] }
    return "N/A" unless fare

    format_price(fare[:price_in_cents], fare[:currency])
  end

  # Maps a currency code to its display symbol.
  # @param currency [String, nil]
  # @return [String]
  def currency_symbol(currency)
    case currency&.upcase
    when "EUR" then "€"
    when "USD" then "$"
    when "CAD" then "$"
    when "GBP" then "£"
    else currency || ""
    end
  end

  # Formats the changeover count into a label.
  # @param count [Integer]
  # @return [String]
  def format_changeovers(count)
    case count
    when 0 then "Direct"
    when 1 then "1 change"
    else "#{count} changes"
    end
  end

  # Creates a visual string representing changeovers.
  # @param count [Integer]
  # @return [String]
  def changeover_visual(count)
    return "" if count == 0

    Array.new(count, "→ ·").join(" ")
  end
end
