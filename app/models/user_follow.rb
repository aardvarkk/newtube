class UserFollow < ActiveRecord::Base
  belongs_to :user
  belongs_to :show
  attr_accessible :show_id, :user_id
end
