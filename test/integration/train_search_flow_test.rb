require "test_helper"

class TrainSearchFlowTest < ActionDispatch::IntegrationTest
  test "complete search flow from index to results" do
    get bot_thetrainline_index_path
    assert_response :success
    assert_select "h1", "Find Trains"

    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end

  test "user can modify search from results page" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }
    assert_response :success

    get bot_thetrainline_search_path, params: {
      from: "Barcelona",
      to: "Sevilla",
      departure_at: "2026-02-16T15:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end

  test "user can go back to index from results" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }
    assert_response :success
    assert_select "a", "← Back"

    get bot_thetrainline_index_path
    assert_response :success
    assert_select "h1", "Find Trains"
  end

  test "journey details display correct information" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-details", /Madrid/
    assert_select ".journey-details", /Barcelona/
    assert_select ".journey-details", /February 16, 2026/
  end

  test "search results display price information" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".price-amount"
  end

  test "search results display duration information" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-duration"
  end

  test "search results display changeover information" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-details-info", /Changes:/
  end

  test "results show available fares" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".fare-section"
    assert_select ".fare-item"
  end

  test "error message persists form data" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Madrid",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".alert-error"
    assert_select "input[name='from'][value='Madrid']"
  end

  test "valid search clears error messages" do
    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Madrid",
      departure_at: "2026-02-16T09:00"
    }
    assert_select ".alert-error"

    get bot_thetrainline_search_path, params: {
      from: "Madrid",
      to: "Barcelona",
      departure_at: "2026-02-16T09:00"
    }

    assert_response :success
    assert_select ".journey-card"
  end

  test "empty search shows appropriate error" do
    get bot_thetrainline_search_path, params: {
      from: "",
      to: "",
      departure_at: ""
    }

    assert_response :success
    assert_select ".alert-error"
  end
end
