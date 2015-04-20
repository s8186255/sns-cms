class InfoCounter < ActiveRecord::Base
  belongs_to :info


  def self.add_comment_count(info_id)
    info_counter = InfoCounter.find_by_info_id info_id
    unless info_counter.nil?
      info_counter.update_attributes :comment_count=>info_counter.comment_count + 1
    else
      InfoCounter.create :info_id=>info_id,:comment_count=>1
    end
  end

  def self.add_view_count(info_id)
    info_counter = InfoCounter.find_by_info_id info_id
    unless info_counter.nil?
      info_counter.update_attributes :view_count=>info_counter.view_count + 1
    else
      InfoCounter.create :info_id=>info_id,:view_count=>1
    end
  end

end
