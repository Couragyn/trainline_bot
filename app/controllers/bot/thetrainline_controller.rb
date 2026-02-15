require_relative "../../lib/train_search/errors"

class Bot::ThetrainlineController < ApplicationController
  rescue_from TrainSearch::DataSourceUnavailableError, with: :handle_data_unavailable

  def index
    # Display search form
  end

  def search
    @from = search_params[:from]&.strip
    @to = search_params[:to]&.strip
    @departure_at = search_params[:departure_at]

    Rails.logger.info("Search request: #{@from} → #{@to} at #{@departure_at}")

    validator = TrainSearchValidator.new(@from, @to, @departure_at)

    if validator.valid?
      @departure_at = TrainSearchValidator.parse_departure_at(@departure_at)
      @results = search_service.search(@from, @to, @departure_at)

      render :search
    else
      Rails.logger.debug("Search validation failed: #{validator.errors.join(', ')}")
      flash.now[:error] = validator.errors.join(". ")
      render :index
    end
  end

  private

  def search_params
    params.permit(:from, :to, :departure_at)
  end

  def search_service
    @search_service ||= TrainSearchService.new
  end

  def handle_data_unavailable(exception)
    Rails.logger.error("Data source unavailable: #{exception.message}")
    Rails.logger.error("Context: #{exception.context.inspect}") if exception.context.any?

    flash.now[:error] = "The train search service is temporarily unavailable. Please try again in a few minutes."
    render :index, status: :service_unavailable
  end
end
