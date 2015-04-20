class ItemType < ActiveRecord::Base
  belongs_to :info_type
  has_many :items
  belongs_to :content_type

  
end
