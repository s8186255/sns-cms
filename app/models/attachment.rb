class Attachment < ActiveRecord::Base
  belongs_to :item
  has_attachment  :storage => :file_system,
   :max_size => 100.megabytes,
  :thumbnails => {:thumb => [20,20], :tiny =>[10,10] }
  # :processor => :Rmagick
  #:content_type => ['application/pdf', 'application/msword', 'text/plain']
  validates_as_attachment
end
