class TopicType < ActiveRecord::Base
  #递归定义
  belongs_to :parent,:class_name => 'TopicType',:foreign_key=>'parent_id'
  has_many :children,:class_name => 'TopicType',:foreign_key=>'parent_id'
  
  has_many :topics,:foreign_key=>:topic_type_id

  belongs_to :user

end
