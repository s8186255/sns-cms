class Role < ActiveRecord::Base
  has_many :users,:foreign_key=>'role_id'
end
