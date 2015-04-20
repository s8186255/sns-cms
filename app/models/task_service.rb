class TaskService
  attr_reader :task, :attachment

  def initialize(task, attachments)
    @task = task
    @attachments = attachments
  end

  def save
    return false unless valid?
    begin
      Task.transaction do
        @attachments.each do |attachment|
          if attachment.new_record?
            @task.attachment.find(attachment).destroy if @task.attachments.include?(attachment)
            attachment.task = @task
            attachment.save!
          end
        end
        @task.save!
        true
      end
    end
  end

  def update_attributes(task_attributes, attachment_file)
    @task.attributes = task_attributes
    unless attachment_file.nil?
      @attachments = []
      attachment_file.each do |file|
        @attachments << Attachment.new(:uploaded_data => file)
      end
    end
    save
  end

  def valid?
    @task.valid? && valid_attachments?
  end

  def valid_attachments?
    @attachments.each do |attachment|
      return false unless attachment.valid?
    end
    true
  end
end