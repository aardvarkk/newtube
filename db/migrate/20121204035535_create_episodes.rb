class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :name
      t.integer :number
      t.integer :season
      t.integer :tvdbid
      t.integer :show_id
      
      t.timestamps
    end
  end
end
