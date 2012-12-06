class UsersController < ApplicationController
  include TVDB
  before_filter :login_required, :except => [:new, :create]

  def index

    # What shows does this user follow?
    follow_shows = current_user.shows.order(:name)

    # Go through each follow, storing the show name
    @data = Array.new
    follow_shows.each do |fs|

      # Get all of the episode info
      episodes = Array.new
      Episode.joins('left join user_watches on id = user_watches.episode_id').order(:season, :number).where(show_id: fs.id).each do |e|
        episode = Hash.new
        episode[:id]      = e.id
        episode[:season]  = e.season
        episode[:number]  = e.number
        episode[:name]    = e.name
        episode[:watched] = e.user_watches.where(user_id: current_user)
        episodes << episode
      end

      show_data = Hash.new
      show_data[:id]       = fs.id
      show_data[:name]     = fs.name
      show_data[:episodes] = episodes

      # Add to our dataset
      @data << show_data

    end

  end

  def watch_show
    params[:watched_ids].each do |wid|
      UserWatch.find_or_create_by_user_id_and_episode_id(user_id: current_user.id, episode_id: wid)
    end
    redirect_to index_path
  end

  def add_show

    # Can only create if we're passed an ID...
    if params[:add].blank?
      redirect_to index_path, alert: 'Must provide a show ID' 
      return
    end

    # Do we already have it?
    if UserFollow.joins(:show).where(shows: { tvdbid: params[:add] }).present?
      redirect_to index_path, alert: 'Show already followed' 
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
    current_user.user_follows.create(show_id: show.id)

    # If it does exist, we'll make a call out for the data on it
    redirect_to index_path, notice: 'Show successfully added'

  end

  def remove_show
    current_user.user_follows.where(show_id: params[:remove]).delete_all
    redirect_to index_path, notice: 'Show successfully removed'
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
