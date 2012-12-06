class Episode < ActiveRecord::Base
  belongs_to :show
  has_many :user_watches

  attr_accessible :name, :number, :season, :tvdbid, :first_aired
end
