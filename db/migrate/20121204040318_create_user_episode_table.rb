class CreateUserEpisodeTable < ActiveRecord::Migration
  def up
    create_table :users_episodes, :id => false do |t|
      t.integer :user_id
      t.integer :episode_id
    end
  end

  def down
  end
end
