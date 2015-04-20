class Team < ActiveRecord::Base
  belongs_to :user
  has_many :team_users,:foreign_key=>'team_id'
  has_many :team_topics,:foreign_key=>'team_id'
end
