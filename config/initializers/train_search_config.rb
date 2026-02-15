module TrainSearchConfig
  class << self
    def fixture_data_path
      ENV.fetch("TRAIN_DATA_PATH", Rails.root.join("lib", "fixtures", "train_data.json").to_s)
    end

    def cache_key_prefix
      ENV.fetch("TRAIN_CACHE_PREFIX", "train_repository")
    end

    def cache_expiration
      ENV.fetch("TRAIN_CACHE_EXPIRATION_SECONDS", 1.hour.to_i).to_i.seconds
    end

    def min_search_date
      DateTime.new(2026, 2, 16, 0, 0, 0, "+01:00")
    end

    def max_search_date
      DateTime.new(2027, 2, 22, 0, 0, 0, "+01:00")
    end

    def log_level
      ENV.fetch("TRAIN_LOG_LEVEL", Rails.env.production? ? "info" : "debug").to_sym
    end

    def max_results
      ENV.fetch("TRAIN_MAX_RESULTS", 50).to_i
    end
  end
end
