class UsersController < ApplicationController
  include TVDB
  before_filter :login_required, :except => [:new, :create]

  def index
    # Return all relevant data
    @follows = current_user.user_follows
    @watches = current_user.user_watches
  end

  def add_show

    # Can only create if we're passed an ID...
    if params[:add].blank?
      redirect_to user_shows_path(current_user), alert: 'Must provide a show ID' 
      return
    end

    # Try to find the show in the database
    show = Show.find_by_tvdbid(params[:add])

    # If it's not in the database...
    unless show
      # Have to retrieve the info for the show and save it to the database
      
      # Try to do a pull from thetvdb.com
      tvdb = tvdb_query_series_all(params[:add])
      logger.debug tvdb

      # First off, add the show itself
      show = Show.create({name: tvdb['Data']['Series']['SeriesName'], tvdbid: tvdb['Data']['Series']['id']})

      # Add episodes to the show
      tvdb['Data']['Episode'].each do |e|
        episode = Episode.create({name: e['EpisodeName'], number: e['EpisodeNumber'], season: e['SeasonNumber'], tvdbid: e['id']})
        show.episodes << episode
      end

    end

    # Add it to our user's follows
    UserFollow.create({user_id: current_user.id, show_id: show.id})

    # If it does exist, we'll make a call out for the data on it
    redirect_to index_path(current_user), notice: 'Show successfully added'

  end

  def remove_show
    current_user.user_follows.where(show_id: params[:remove]).delete_all
    redirect_to index_path(current_user), notice: 'Show successfully removed'
  end

  # This is our root, so if we're logged in, we'll redirect to #show
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, :notice => "Thank you for signing up! You are now logged in."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to root_url, :notice => "Your profile has been updated."
    else
      render :action => 'edit'
    end
  end

end
