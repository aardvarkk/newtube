class Show < ActiveRecord::Base
  has_many :episodes
  has_and_belongs_to_many :users, join_table: :users_shows

  attr_accessible :name, :tvdbid
end
