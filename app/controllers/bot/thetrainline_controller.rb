class Bot::ThetrainlineController < ApplicationController
  def index
    # Display search form
  end

  def search
    @from = params[:from]&.strip
    @to = params[:to]&.strip
    @departure_at = params[:departure_at]

    errors = []
    errors << "Departure city or station is required" if @from.blank?
    errors << "Arrival city or station is required" if @to.blank?
    errors << "Departure date and time is required" if @departure_at.blank?

    if @departure_at.present?
      begin
        parsed_date = DateTime.parse(@departure_at)
        min_date = DateTime.new(2026, 2, 16, 0, 0, 0, "+01:00")
        max_date = min_date + 365.days
        
        if parsed_date < min_date
          errors << "Departure date cannot be before February 16, 2026"
        elsif parsed_date > max_date
          errors << "Departure date cannot be more than one year in advance"
        else
          @departure_at = parsed_date
        end
      rescue ArgumentError
        errors << "Invalid date and time format"
      end
    end

    if @from.present? && @to.present? && @from.downcase == @to.downcase
      errors << "Departure and arrival locations must be different"
    end

    if errors.any?
      flash.now[:error] = errors.join(". ")
      render :index
    else
      @results = Bot::Thetrainline.find(@from, @to, @departure_at)
      render :search
    end
  end
end
