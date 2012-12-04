class ShowsController < ApplicationController
  before_filter :login_required

  def index
    # Set up some test data
    @shows = ['Elementary', 'Hart of Dixie']
  end

  def create
    # Try to find the show in the database
    redirect_to user_shows_path(current_user), notice: 'Hi!'
  end

end
