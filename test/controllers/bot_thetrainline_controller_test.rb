require "test_helper"

class Bot::ThetrainlineControllerTest < ActionDispatch::IntegrationTest
  test "should GET index and render search form" do
    get bot_thetrainline_index_path
    assert_response :success
    assert_select "h1", "Find Trains"
    assert_select "form[action=?]", search_bot_thetrainline_index_path
    assert_select "input[name='from']"
    assert_select "input[name='to']"
    assert_select "input[name='departure_at']"
  end

  test "should GET search with valid parameters and display results" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-22T09:00"
    }
    assert_response :success
    assert_select "h1", "Results"
    assert_select ".journey-card"
    assert_select ".journey-details"
    assert_select ".journey-details", /Madrid/
    assert_select ".journey-details", /Barcelona/
    assert_select "a", "← Back"
    assert_select "input[name='from'][value='Madrid']"
    assert_select "input[name='to'][value='Barcelona']"
    assert_select ".journey-times"
    assert_select ".journey-price"
    assert_select ".journey-duration"
    assert_select ".journey-details-info"
    assert_select ".fare-section"
    assert_select ".fare-item"
    assert_select ".fare-price"
    cards = css_select ".journey-card"
    assert_operator cards.length, :>, 1, "Should have multiple results"
  end

  test "should strip whitespace from parameters" do
    get search_bot_thetrainline_index_path, params: {
      from: "  Madrid  ",
      to: "  Barcelona  ",
      departure_at: "2026-02-22T09:00"
    }

    assert_response :success
    assert_select ".results"
  end

  test "should handle case-insensitive search" do
    get search_bot_thetrainline_index_path, params: {
      from: "madrid",
      to: "barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end

  test "should show 'No trains found' for non-existent route" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "NonExistentCity",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".no-results", /No trains found/
  end

  test "should display error when from is missing" do
    get search_bot_thetrainline_index_path, params: {
      from: "",
      to: "Barcelona",
      departure_at: "2026-02-22T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
    assert_select "input[name='from']"
  end

  test "should display error when to is missing" do
    get search_bot_thetrainline_index_path, params: {
      to: "",
      from: "Madrid",
      departure_at: "2026-02-22T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error when departure_at is missing" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: ""
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error when from and to are the same" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Madrid",
      departure_at: "2026-02-22T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for date before minimum" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-15T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for date after maximum" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2027-02-23T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
  end

  test "should display error for invalid date format" do
    get search_bot_thetrainline_index_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "invalid-date"
    }

    assert_response :success
    assert_select ".alert-error"
  end
end
