# Find Trains

A simple Rails app for searching train journeys. Built to meet the requirements [here](https://gist.github.com/jonathonbellew-lp/68fca019a68e630c186e4030b8436f91).

## What It Does

Search for train trips between cities. Get departure/arrival times, duration, number of stops, and available fares.

## Getting Started

**Requirements:**
- Ruby 3.3.8
- Rails 8.1.2
- Node.js (for assets)

**Setup:**
```bash
bundle install
rails s
```

Visit `http://localhost:3000`

## Data

The app searches against fixture data in `lib/fixtures/train_data.json`. Available routes are between Madrid, Barcelona, Sevilla, and Valencia for Feb 16-22, 2026.

## Testing

Run the test suite:
```bash
rails test
```

102 tests covering models, controllers, integration flows, edge cases, and fixture validation. Takes about 400ms.

See `test/TEST_SUITE.md` for details.

## How It Works

1. Enter departure city or station, arrival city or station, and departure date
2. Click search
3. See available journeys with times, duration, and fare options
4. Each journey shows the cost and any stops along the way

The form validates that:
- Both cities are provided
- You're not searching the same station twice
- The date is after Feb 16, 2026

## Project Structure

```
app/
  models/bot/thetrainline.rb       # Search logic
  controllers/bot/                 # Request handling
  views/bot/thetrainline/          # Search form and results
  assets/stylesheets/              # CSS with teal theme

lib/fixtures/train_data.json       # Test data
test/                              # Test suite
```
