class UserWatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :episode
  attr_accessible :episode_id, :user_id
end
