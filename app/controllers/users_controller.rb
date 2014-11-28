class UsersController < ApplicationController
  include ERB::Util
  include TVDB
  before_filter :login_required, :except => [:new, :create]

  def show

    # What shows does this user follow?
    follow_shows = current_user.shows.order(:name)

    # Go through each follow, storing the show name
    @data = Array.new
    follow_shows.each do |fs|

      # Get all of the episode info
      episodes = Array.new
      Episode.joins('left join user_watches on id = user_watches.episode_id').order(:first_aired, :season, :number).where(show_id: fs.id).each do |e|
        episode = Hash.new
        episode[:id]          = e.id
        episode[:season]      = e.season
        episode[:number]      = e.number
        episode[:name]        = e.name
        episode[:watched]     = e.user_watches.where(user_id: current_user)
        episode[:first_aired] = e.first_aired
        episodes << episode if params[:show_all].present? || episode[:watched].blank?
      end

      show_data = Hash.new
      show_data[:id]       = fs.id
      show_data[:name]     = fs.name
      show_data[:episodes] = episodes

      # Add to our dataset
      @data << show_data

    end

  end

  # We need to know the show id so that we can search to see if this episode already exists
  def add_episodes(tvdb, show_id)

    # Add episodes to the show
    episodes = Array.new

    # Go through all episodes returned to us
    Array.wrap(tvdb['Data']['Episode']).each do |e|

      # Find or create, and then update
      episode = Episode.find_or_create_by_show_id_and_season_and_number(show_id, e['SeasonNumber'], e['EpisodeNumber'])
      
      # Update the info
      episode.name        = e['EpisodeName']
      episode.tvdbid      = e['id']
      episode.first_aired = e['FirstAired']
      episode.save
      
      # Put it into our episodes group
      episodes << episode

    end

    return episodes
  end

  # Must have a valid show id -- we already have the show in our database, we just want to find new episodes

  def update_show
    show = Show.find_by_id(params[:update])
    redirect_to users_path, alert: 'Unable to update show' unless show

    # Try to do a pull from thetvdb.com
    tvdb = tvdb_query_series_all(show.tvdbid)
    show.episodes = add_episodes(tvdb, show.id)

    redirect_to users_path, notice: 'Show successfully updated'
  end

  def set_show_status
    if params[:status] == '1'
      params[:watched_ids].each do |wid|
        UserWatch.find_or_create_by_user_id_and_episode_id(user_id: current_user.id, episode_id: wid)
      end
    else
      UserWatch.where(user_id: current_user.id, episode_id: params[:watched_ids]).delete_all
    end
    redirect_to users_path
  end

  def search_show
    @tvdb = tvdb_search_series(URI.escape(params[:search] || ''))
  end

  def add_show

    # Can only create if we're passed an ID...
    if params[:add].blank?
      redirect_to users_path, alert: 'Must provide a show ID' 
      return
    end

    # Do we already have it?
    if UserFollow.joins(:show).where(user_id: current_user, shows: { tvdbid: params[:add] }).present?
      redirect_to user_path(current_user), alert: 'Show already followed' 
      return
    end

    # Try to find the show in the database
    show = Show.find_by_tvdbid(params[:add])

    # If it's not in the database...
    unless show
      # Have to retrieve the info for the show and save it to the database
      
      # Try to do a pull from thetvdb.com
      tvdb = tvdb_query_series_all(params[:add])

      # First off, add the show itself
      show = Show.create({name: tvdb['Data']['Series']['SeriesName'], tvdbid: tvdb['Data']['Series']['id']})
      
      # Then add the episodes
      show.episodes = add_episodes(tvdb, show.id)

    end

    # Add it to our user's follows
    current_user.user_follows.create(show_id: show.id)

    # If it does exist, we'll make a call out for the data on it
    redirect_to user_path(current_user), notice: 'Show successfully added'

  end

  def remove_show
    # Get the show we're trying to remove
    show = Show.find_by_id(params[:remove])
    # Remove any episode watches for this show
    UserWatch.where(user_id: current_user.id, episode_id: show.episodes).delete_all
    # Remove the show follow itself
    UserFollow.where(user_id: current_user.id, show_id: show.id).delete_all
    redirect_to users_path, notice: 'Show successfully removed'
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
