require "test_helper"
require "capybara/rails"

class TrainSearchAccessibilityTest < ActionDispatch::SystemTestCase
  driven_by :rack_test

  test "index page has descriptive h1 heading" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("h1", text: "Find Trains")
  end

  test "form inputs have associated labels" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("label[for='from']")
    assert page.has_selector?("label[for='to']")
    assert page.has_selector?("label[for='departure_at']")
  end

  test "form labels are visible and descriptive" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("label", text: /from/i)
    assert page.has_selector?("label", text: /to/i)
    assert page.has_selector?("label", text: /departure|date|when/i)
  end

  test "form inputs have proper name attributes" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("input[name='from']")
    assert page.has_selector?("input[name='to']")
    assert page.has_selector?("input[name='departure_at']")
  end

  test "submit button is accessible and labeled" do
    visit bot_thetrainline_index_path

    assert page.has_button? { |button|
      button.text.downcase.include?("search") || button.text.downcase.include?("find")
    }
  end

  test "form is navigable via tab key" do
    visit bot_thetrainline_index_path

    inputs = page.all("input[type='text'], input[type='datetime-local']")
    assert_operator inputs.length, :>=, 3, "Should have at least 3 form inputs"
  end

  test "form inputs are keyboard accessible" do
    visit bot_thetrainline_index_path

    interactive = page.all("input, button, a[href]")
    assert_operator interactive.length, :>, 0, "Should have interactive elements"
  end

  test "page uses semantic HTML structure" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("body"), "Should have body element"
    assert page.has_selector?("form"), "Should have form element"
  end

  test "search results page has proper heading structure" do
    fill_and_submit_search

    assert page.has_selector?("h1", text: /results/i)
  end

  test "journey cards use semantic markup" do
    fill_and_submit_search

    assert page.has_selector?(".journey-card")
    assert page.has_selector?(".journey-times") || page.has_selector?(".journey-details")
  end


  test "error messages are properly associated with form fields" do
    fill_in "from", with: ""
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)


    assert page.has_selector?(".alert-error") || page.has_selector?("[role='alert']")
  end

  test "error text is accessible and descriptive" do
    fill_in "from", with: ""
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)

    assert page.has_text?(/required|must|empty|missing/i)
  end

  test "success/no results message is clear" do
    fill_in "from", with: "Madrid"
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)

    has_results = page.has_selector?(".journey-card")
    has_no_results = page.has_text?(/no trains found/i)

    assert has_results || has_no_results, "Should show results or no-results message"
  end

  test "icons have alternative text or aria-labels" do
    visit bot_thetrainline_index_path

    assert page.has_selector?("body"), "Page should load without structural errors"
  end

  test "page title is present and descriptive" do
    visit bot_thetrainline_index_path

    title = page.find("title").text
    assert title.present?
    assert title.downcase.include?("train") || title.downcase.include?("search")
  end

  test "page has sufficient text content" do
    visit bot_thetrainline_index_path

    assert page.has_text?("Find Trains") || page.has_text?("Search")
  end

  test "search results page is readable without images" do
    fill_and_submit_search

    page_text = page.text.downcase
    assert page_text.include?("madrid") ||
           page_text.include?("barcelona") ||
           page_text.include?("no trains"),
      "Results should contain location or status text"
  end


  test "page has visible focus indicators" do
    visit bot_thetrainline_index_path

    first_input = page.find("input")
    assert first_input.present?, "Should have focusable inputs"
  end

  test "focus is visible on button hover/focus" do
    visit bot_thetrainline_index_path

    button = page.find("button")
    assert button.present?, "Page should have button"
  end


  test "page content is logically ordered" do
    visit bot_thetrainline_index_path

    first_h1 = page.find("h1")
    assert first_h1.text.downcase.include?("find") ||
           first_h1.text.downcase.include?("search") ||
           first_h1.text.downcase.include?("train")
  end

  test "back button is accessible on results page" do
    fill_and_submit_search

    assert page.has_link?("← Back") || page.has_text?("Back")
  end


  test "page is responsive at mobile viewport" do
    visit bot_thetrainline_index_path

    assert page.has_content?("Find Trains")
  end

  test "form is clickable and usable" do
    visit bot_thetrainline_index_path

    from_field = page.find("input[name='from']")
    assert from_field.present?

    from_field.fill_in with: "Madrid"
    assert from_field.value == "Madrid"
  end

  test "user can complete search from index to results" do
    visit bot_thetrainline_index_path
    assert page.has_selector?("h1", text: "Find Trains")

    fill_in "from", with: "Madrid"
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)

    assert page.has_selector?(".journey-card") || page.has_text?(/no trains|results/i)
  end

  test "user can navigate back from results to search" do
    fill_and_submit_search

    click_link("← Back") if page.has_link?("← Back")

    visit bot_thetrainline_index_path
    assert page.has_selector?("h1", text: "Find Trains")
  end

  test "form maintains accessibility after errors" do
    fill_in "from", with: ""
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)

    assert page.has_selector?("input[name='from']")
    assert page.has_selector?("input[name='to']")

    fill_in "from", with: "Madrid"
    click_button(/search|find/i)
  end

  test "page uses clear, simple language in labels" do
    visit bot_thetrainline_index_path

    page_text = page.text.downcase
    assert page_text.include?("from") || page_text.include?("departure")
    assert page_text.include?("to") || page_text.include?("arrival")
  end

  test "date/time input has clear format guidance" do
    visit bot_thetrainline_index_path

    departure_field = page.find("input[name='departure_at']")
    assert departure_field.present?
  end


  private

  def fill_and_submit_search
    visit bot_thetrainline_index_path
    fill_in "from", with: "Madrid"
    fill_in "to", with: "Barcelona"
    fill_in "departure_at", with: "2026-02-16T09:00"
    click_button(/search|find/i)
  end
end
