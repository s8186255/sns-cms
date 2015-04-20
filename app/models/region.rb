class Region < ActiveRecord::Base
  belongs_to :parent_region,:class_name => 'Region',:foreign_key=>'parent_region_id'
  has_many :child_regions,:class_name => 'Region',:foreign_key=>'parent_region_id'

  has_many :users,:foreign_key=>'region_id'
  has_many :topics,:foreign_key=>'region_id'

end
