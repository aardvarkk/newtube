class Show < ActiveRecord::Base
  has_many :episodes
  has_many :user_follows
  
  attr_accessible :name, :tvdbid
end
