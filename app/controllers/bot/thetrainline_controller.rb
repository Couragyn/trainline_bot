class Bot::ThetrainlineController < ApplicationController
  def index
    # Display search form
  end

  def search
    @from = search_params[:from]&.strip
    @to = search_params[:to]&.strip
    @departure_at = search_params[:departure_at]

    errors = Bot::Thetrainline.validate_search_params(@from, @to, @departure_at)

    if errors.any?
      flash.now[:error] = errors.join(". ")
      render :index
    else
      @departure_at = Bot::Thetrainline.parse_departure_at(@departure_at)
      @results = Bot::Thetrainline.find(@from, @to, @departure_at)
      render :search
    end
  end

  private

  def search_params
    params.permit(:from, :to, :departure_at)
  end
end
