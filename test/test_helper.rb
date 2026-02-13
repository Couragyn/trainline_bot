ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  def fixture_data
    @fixture_data ||= load_fixture_data
  end

  def load_fixture_data
    file_path = Rails.root.join("lib", "fixtures", "train_data.json")
    JSON.parse(File.read(file_path))
  end

  def fixture_segments
    fixture_data["segments"] || []
  end

  def find_fixture_route(from, to, date)
    Bot::Thetrainline.find(from, to, date)
  end
end
