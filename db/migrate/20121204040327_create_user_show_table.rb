class CreateUserShowTable < ActiveRecord::Migration
  def up
    create_table :users_shows, :id => false do |t|
      t.integer :user_id
      t.integer :show_id
    end
  end

  def down
  end
end
