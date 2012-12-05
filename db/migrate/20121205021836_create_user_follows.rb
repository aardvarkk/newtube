class CreateUserFollows < ActiveRecord::Migration
  def change
    create_table :user_follows, id: false do |t|
      t.integer :user_id
      t.integer :show_id

      t.timestamps
    end
  end
end
