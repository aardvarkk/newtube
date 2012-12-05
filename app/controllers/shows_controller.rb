class ShowsController < ApplicationController
  include TVDB
  before_filter :login_required

  def index
    # Return all relevant data
    @shows = current_user.shows
    @episodes = Array.new
    @shows.each do |s|
      @episodes << current_user.episodes.where(show_id: s.id)
    end
  end

  def create
    # Can only create if we're passed an ID...
    if params[:add].blank?
      redirect_to user_shows_path(current_user), alert: 'Must provide a show ID' 
      return
    end

    # Try to find the show in the database
    show = Show.find_by_tvdbid(params[:add])

    # If we found it already in the database (somebody else is a fan...)
    if show
      # Add it to the user's shows
      current_user.shows << show
    else
      # Have to retrieve the info for the show and save it to the database
      
      # Try to do a pull from thetvdb.com
      tvdb = tvdb_query_series_all(params[:add])

      # First off, add the show itself
      show = Show.create({name: tvdb['Data']['Series']['SeriesName'], tvdbid: tvdb['Data']['Series']['id']})
      current_user.shows << show

      # Add episodes to the show AND to the user
      # Then add the episodes
      tvdb['Data']['Episode'].each do |e|
        episode = Episode.create({name: e['EpisodeName'], number: e['EpisodeNumber'], season: e['SeasonNumber'], tvdbid: e['id']})
        show.episodes << episode
        current_user.episodes << episode
      end

    end

    # If it does exist, we'll make a call out for the data on it
    redirect_to user_shows_path(current_user), notice: 'Show successfully added'
  end

end
