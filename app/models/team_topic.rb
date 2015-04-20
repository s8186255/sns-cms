class TeamTopic < ActiveRecord::Base
  belongs_to :topic
  belongs_to :team
end
