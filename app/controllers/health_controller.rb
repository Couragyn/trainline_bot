class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:show, :deep]

  def show
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601
    }
  end

  def deep
    checks = {
      cache: check_cache,
      train_data: check_train_data
    }

    all_healthy = checks.values.all? { |check| check[:healthy] }
    status_code = all_healthy ? :ok : :service_unavailable

    render json: {
      status: all_healthy ? 'ok' : 'degraded',
      timestamp: Time.current.iso8601,
      checks: checks
    }, status: status_code
  end

  private

  def check_cache
    test_key = 'health_check_test'
    Rails.cache.write(test_key, 'test', expires_in: 1.second)
    result = Rails.cache.read(test_key)
    Rails.cache.delete(test_key)

    if result == 'test'
      { healthy: true, message: 'Cache is working' }
    else
      { healthy: false, message: 'Cache read/write failed' }
    end
  rescue StandardError => e
    Rails.logger.error("Health check - Cache failed: #{e.message}")
    { healthy: false, message: "Cache error: #{e.message}" }
  end

  def check_train_data
    repository = TrainRepository.new
    
    if repository.healthy?
      { healthy: true, message: 'Train data is accessible' }
    else
      { healthy: false, message: 'Train data is not accessible' }
    end
  rescue StandardError => e
    Rails.logger.error("Health check - Train data failed: #{e.message}")
    { healthy: false, message: "Train data error: #{e.message}" }
  end
end
