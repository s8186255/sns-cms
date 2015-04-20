class Avatar < ActiveRecord::Base
  has_attachment  :content_type => :image,
    :storage => :file_system,
    :path_prefix=>'/public/avatars',
    :resize_to => [50,50]
    #:max_size => 100.megabytes,
  #:thumbnails => {:thumb => [20,20]}
  #:processor => :Rmagick
  #:content_type => ['application/pdf', 'application/msword', 'text/plain']
  validates_as_attachment

  
end
