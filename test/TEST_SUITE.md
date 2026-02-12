# Test Suite

## Quick Start

Run all tests:
```bash
rails test
```

Run a specific test file:
```bash
rails test test/models/bot_thetrainline_test.rb
```

Run tests with output:
```bash
rails test -v
```

Run a single test:
```bash
rails test test/models/bot_thetrainline_test.rb -n test_find_returns_an_array
```

## What's Tested

**Models (22 tests)** - The `Bot::Thetrainline` search logic. Validates that we're returning the right data structure with valid dates, prices, and routes.

**Controllers (25 tests)** - Form handling and validation. Makes sure we catch missing fields, invalid dates, and show proper error messages.

**Integration (11 tests)** - Real user flows. Test that everything works together from searching to seeing results.

**Edge Cases (27 tests)** - Boundary dates, special characters, timezone handling, unusual journey scenarios.

**Fixture Validation (24 tests)** - Makes sure the test data is clean and consistent.

## Test Data

Tests use fake data from `lib/fixtures/train_data.json`. The main routes are Madrid ↔ Barcelona and Barcelona ↔ Sevilla for Feb 16-22, 2026.

## What We Check

**Happy path:** Valid search returns results with journey times, prices, and stops.

**Errors:** Missing fields, same departure/arrival city, date out of range, bad date format all show error messages.

**Edge cases:** Case-insensitive city names, whitespace handling, multi-stop journeys, overnight trips.

## Notes

- All tests use fixture data, no external APIs
- Tests are deterministic (same data every time)
- You can run tests in parallel
