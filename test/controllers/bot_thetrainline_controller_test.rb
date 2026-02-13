require "test_helper"

class Bot::ThetrainlineControllerTest < ActionDispatch::IntegrationTest
  test "should GET index" do
    get bot_thetrainline_index_path
    assert_response :success
    assert_select "h1", "Find Trains"
  end

  test "should render search form on index" do
    get bot_thetrainline_index_path
    assert_select "form[action=?]", bot_thetrainline_search_path
    assert_select "input[name='from']"
    assert_select "input[name='to']"
    assert_select "input[name='departure_at']"
  end

  test "should GET search with valid parameters" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }
    assert_response :success
  end

  test "should display search results on successful search" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select "h1", "Results"
  end

  test "should display error when from is missing" do
    get bot_thetrainline_search_path, params: {
      from: "",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
    assert_select "input[name='from']"
  end

  test "should display error when to is missing" do
    get bot_thetrainline_search_path, params: {
      to: "",
      from: "Madrid",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error when departure_at is missing" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: ""
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error when from and to are the same" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Madrid",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for date before minimum" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-15T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for date after maximum" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2027-02-17T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for invalid date format" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "invalid-date"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display search results with journey cards" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end

  test "should display journey details section" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-details"
    assert_select ".journey-details", /Madrid/
    assert_select ".journey-details", /Barcelona/
  end

  test "should strip whitespace from parameters" do
    get bot_thetrainline_search_path, params: {
      from: "  Madrid  ",
      to: "  Barcelona  ",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".results"
  end

  test "should display back button on search results" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select "a", "← Back"
  end

  test "should persist search parameters in modify search form" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select "input[name='from'][value='Madrid']"
    assert_select "input[name='to'][value='Barcelona']"
  end

  test "should show journey card details" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-times"
    assert_select ".journey-price"
    assert_select ".journey-duration"
    assert_select ".journey-details-info"
  end

  test "should show fare information in journey card" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".fare-section"
    assert_select ".fare-item"
    assert_select ".fare-price"
  end

  test "search with valid Madrid to Barcelona should have multiple results" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    cards = css_select ".journey-card"
    assert_operator cards.length, :>, 1, "Should have multiple results"
  end

  test "should show 'No trains found' for non-existent route" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "NonExistentCity",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".no-results", /No trains found/
  end

  test "should handle case-insensitive search" do
    get bot_thetrainline_search_path, params: {
      from: "madrid",
      to: "barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end
end
