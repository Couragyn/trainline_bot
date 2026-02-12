ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  def fixture_data
    @fixture_data ||= load_fixture_data
  end

  def load_fixture_data
    file_path = Rails.root.join('lib', 'fixtures', 'train_data.json')
    JSON.parse(File.read(file_path))
  end

  def fixture_segments
    fixture_data['segments'] || []
  end

  def find_fixture_route(from, to, date)
    segments = fixture_segments
    segments.select do |segment|
      matches_from = segment['departure_city'].casecmp?(from) || segment['departure_station'].casecmp?(from)
      matches_to = segment['arrival_city'].casecmp?(to) || segment['arrival_station'].casecmp?(to)
      matches_date = DateTime.parse(segment['departure_at']).to_date == date.to_date
      matches_from && matches_to && matches_date
    end
  end
end
