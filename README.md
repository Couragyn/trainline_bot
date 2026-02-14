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

The requirements were that this bot needs triggers searches on https://www.thetrainline.com, but that I did not need to solve any of the anti-bot logic they have, and it's fine to use a local static version of the data.

Running a `GET` request with the network tab opens blocks the requests with the error message `Access is temporarily restricted`. This is likely due to their anti-bot logic.

As such I have based the fixture data structure on the Segment Output snippet from the task Gist.

## Testing

Run the test suite:
```bash
rails test
```

100+ tests covering models, controllers, integration flows, edge cases, and fixture validation. Currently takes about 400ms.

See `test/TEST_SUITE.md` for details.

## How It Works

### CLI

1. `rails c`
2. `Bot::Thetrainline.find('Madrid', 'Barcelona', DateTime.new(2026, 2, 16, 9, 0, 0))`
3. View an array of elements, each containing an option for a trip

### GUI

1. Enter departure city or station, arrival city or station, and departure date
2. Click search
3. See available journeys with times, duration, and fare options
4. Each journey shows the cost and any stops along the way

The form validates that:
- Both cities are provided
- You're not searching the same station twice
- The date is between Feb 16, 2026 and Feb 22, 2027

## Project Structure

```
app/
  models/bot/thetrainline.rb       # Search logic
  controllers/bot/                 # Request handling
  views/bot/thetrainline/          # Search form and results
  assets/stylesheets/              # CSS

lib/fixtures/train_data.json       # Test data
test/                              # Test suite
```
