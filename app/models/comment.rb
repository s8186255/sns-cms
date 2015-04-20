class Comment < ActiveRecord::Base
  belongs_to :info,:counter_cache=>true
  belongs_to :user

end
