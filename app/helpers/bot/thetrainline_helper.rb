module Bot::ThetrainlineHelper
  def format_time(datetime)
    datetime.strftime("%H:%M")
  end

  # Format "2h 30m"
  def format_duration(minutes)
    hours = minutes / 60
    mins = minutes % 60
    "#{hours}h #{mins}m"
  end

  # Format "February 16, 2026 at 09:00"
  def format_datetime(datetime)
    datetime.strftime("%B %d, %Y at %H:%M")
  end

  # Format "Renfe, Thetrainline"
  def format_operators(agencies)
    agencies.map(&:titleize).join(", ")
  end

  def cheapest_fare(fares)
    fares.min_by { |f| f[:price_in_cents] }
  end

  # Format "€38.00" or "$50.00"
  def format_price(price_in_cents, currency)
    return "N/A" if price_in_cents.nil?

    symbol = currency_symbol(currency)
    amount = (price_in_cents / 100.0).round(2)
    "#{symbol}#{format('%.2f', amount)}"
  end

  def format_cheapest_price(fares)
    fare = cheapest_fare(fares)
    return "N/A" unless fare

    format_price(fare[:price_in_cents], fare[:currency])
  end

  def currency_symbol(currency)
    case currency&.upcase
    when "EUR" then "€"
    when "USD" then "$"
    when "CAD" then "$"
    when "GBP" then "£"
    else currency || ""
    end
  end

  # Format "1 change" or "Direct"
  def format_changeovers(count)
    case count
    when 0 then "Direct"
    when 1 then "1 change"
    else "#{count} changes"
    end
  end

  # Format "Valencia → · → Sevilla"
  def changeover_visual(count)
    return "" if count == 0

    Array.new(count, "→ ·").join(" ")
  end
end
