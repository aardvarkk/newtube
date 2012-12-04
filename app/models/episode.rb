class Episode < ActiveRecord::Base
  belongs_to :show
  has_and_belongs_to_many :users, join_table: :users_episodes

  attr_accessible :name, :number, :season, :tvdbid
end
