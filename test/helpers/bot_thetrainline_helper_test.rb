require "test_helper"

class Bot::ThetrainlineHelperTest < ActionView::TestCase
  include Bot::ThetrainlineHelper

  test "format_time: formats datetime to HH:MM" do
    datetime = DateTime.new(2026, 2, 16, 9, 30, 0)
    assert_equal "09:30", format_time(datetime)
  end

  test "format_time: handles midnight" do
    datetime = DateTime.new(2026, 2, 16, 0, 0, 0)
    assert_equal "00:00", format_time(datetime)
  end

  test "format_time: handles afternoon times" do
    datetime = DateTime.new(2026, 2, 16, 14, 45, 0)
    assert_equal "14:45", format_time(datetime)
  end

  test "format_duration: handles different durations correctly" do
    assert_equal "2h 30m", format_duration(150)
    assert_equal "1h 0m", format_duration(60)
    assert_equal "0h 45m", format_duration(45)
    assert_equal "12h 15m", format_duration(735)
    assert_equal "0h 0m", format_duration(0)
  end

  test "format_datetime: formats full datetime" do
    datetime = DateTime.new(2026, 2, 16, 9, 30, 0)
    assert_equal "February 16, 2026 at 09:30", format_datetime(datetime)
  end

  test "format_operators: formats single operator" do
    agencies = [ "thetrainline" ]
    assert_equal "Thetrainline", format_operators(agencies)
  end

  test "format_operators: formats multiple operators" do
    agencies = [ "thetrainline", "renfe" ]
    assert_equal "Thetrainline, Renfe", format_operators(agencies)
  end

  test "format_operators: handles empty array" do
    assert_equal "", format_operators([])
  end

  test "cheapest_fare: finds cheapest fare" do
    fares = [
      { name: "Standard", price_in_cents: 5000, currency: "EUR" },
      { name: "Premium", price_in_cents: 8000, currency: "EUR" },
      { name: "Economy", price_in_cents: 3000, currency: "EUR" }
    ]

    result = cheapest_fare(fares)
    assert_equal 3000, result[:price_in_cents]
    assert_equal "Economy", result[:name]
  end

  test "format_price: formats currency price" do
    assert_equal "€38.00", format_price(3800, "EUR")
    assert_equal "$50.00", format_price(5000, "USD")
    assert_equal "$60.00", format_price(6000, "CAD")
    assert_equal "£42.50", format_price(4250, "GBP")
    assert_equal "N/A", format_price(nil, "EUR")
    assert_equal "€12.50", format_price(1250, "EUR")
  end

  test "format_cheapest_price: formats cheapest fare price" do
    fares = [
      { name: "Standard", price_in_cents: 5000, currency: "EUR" },
      { name: "Economy", price_in_cents: 3000, currency: "EUR" }
    ]

    assert_equal "€30.00", format_cheapest_price(fares)
  end

  test "format_cheapest_price: handles empty fares" do
    assert_equal "N/A", format_cheapest_price([])
  end

  test "currency_symbol: returns correct symbols" do
    assert_equal "€", currency_symbol("EUR")
    assert_equal "$", currency_symbol("USD")
    assert_equal "$", currency_symbol("CAD")
    assert_equal "£", currency_symbol("GBP")
    assert_equal "JPY", currency_symbol("JPY")
    assert_equal "", currency_symbol(nil)
    assert_equal "€", currency_symbol("eur")
  end

  test "format_changeovers: formats changeovers" do
    assert_equal "Direct", format_changeovers(0)
    assert_equal "1 change", format_changeovers(1)
    assert_equal "2 changes", format_changeovers(2)
    assert_equal "3 changes", format_changeovers(3)
  end

  test "changeover_visual: formats changeover visual" do
    assert_equal "", changeover_visual(0)
    assert_equal "→ ·", changeover_visual(1)
    assert_equal "→ · → ·", changeover_visual(2)
    assert_equal "→ · → · → ·", changeover_visual(3)
  end
end
