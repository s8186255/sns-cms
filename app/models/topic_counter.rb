class TopicCounter < ActiveRecord::Base
  belongs_to :topic

  def self.add_view_count(topic_id)
    #本方法用在显示topic的时候
    
    topic_counter = TopicCounter.find_by_topic_id topic_id
    unless topic_counter.nil?
      topic_counter.update_attributes :view_count=>topic_counter.view_count + 1
    else
      TopicCounter.create :topic_id=>topic_id,:view_count=>1
    end
  end

  def self.add_following_count(topic_id)
    topic_counter = TopicCounter.find_by_topic_id topic_id
    unless topic_counter.nil?
      topic_counter.update_attributes :following_count=>topic_counter.following_count + 1
    else
      TopicCounter.create :topic_id=>topic_id,:following_count=>1
    end
  end

  def self.add_info_count(topic_id)
    topic_counter = TopicCounter.find_by_topic_id topic_id
    unless topic_counter.nil?
      topic_counter.update_attributes :info_count=>topic_counter.info_count + 1
    else
      TopicCounter.create :topic_id=>topic_id,:info_count=>1
    end
  end
end
