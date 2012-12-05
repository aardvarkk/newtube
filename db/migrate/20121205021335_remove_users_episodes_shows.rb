class RemoveUsersEpisodesShows < ActiveRecord::Migration
  def up
    drop_table :users_episodes
    drop_table :users_shows
  end

  def down
  end
end
