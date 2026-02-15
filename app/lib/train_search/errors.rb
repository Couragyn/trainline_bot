module TrainSearch
  class Error < StandardError
    attr_reader :context

    def initialize(message = nil, context = {})
      @context = context
      super(message)
    end

    def log_error(logger = Rails.logger)
      logger.error("#{self.class.name}: #{message}")
      logger.error("Context: #{context.inspect}") if context.any?
    end
  end

  class DataSourceUnavailableError < Error
    def initialize(message = "Train data source is unavailable", context = {})
      super(message, context)
    end
  end
end
