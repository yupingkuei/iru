class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    if params[:query].present?
      PgSearch::Multisearch.rebuild(policy_scope(Organization))
      PgSearch::Multisearch.rebuild(policy_scope(Event))
      @results = PgSearch.multisearch(params[:query])
    else
      @events = policy_scope(Event)
    end
  end

  def show
  end

  def new
    authorize current_user
    @event = Event.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @organization = Organization.find(params[:organization_id])
    @event = Event.new(event_params)
    authorize @event
    @event.organization = @organization
    @event.owner = current_user
    if @event.save
      redirect_to organization_path(@event.organization)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to organization_path(event.organization)
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to organization_path(@event.organization)
  end

  private

  def set_event
    @event = Event.find(params[:id])
    authorize @event
  end

  def event_params
    params.require(:event).permit(:organization, :user, :category, :title, :description, :ongoing, :start_time, :end_time, :positions, :photo, dates: [])
  end
end
