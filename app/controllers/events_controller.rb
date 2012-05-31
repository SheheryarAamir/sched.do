class EventsController < ApplicationController
  def new
    @event = Event.new
    @suggestion = @event.suggestions.build
  end

  def create
    event = Event.new(params[:event])
    if event.save
      flash[:success] = "Event successfully created."
      redirect_to event
    else
      @event = event
      flash[:error] = "Please complete all required fields."
      render :new
    end
  end

  def show
    @event = Event.find(params[:id])
    @suggestions = @event.suggestions
  end
end