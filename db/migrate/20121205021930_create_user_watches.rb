class CreateUserWatches < ActiveRecord::Migration
  def change
    create_table :user_watches, id: false do |t|
      t.integer :user_id
      t.integer :episode_id

      t.timestamps
    end
  end
end
