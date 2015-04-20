class Task < ActiveRecord::Base
  has_many :attachments, :dependent => :destroy
  validates_presence_of :description
end