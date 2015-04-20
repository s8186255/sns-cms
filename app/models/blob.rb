class Blob < ActiveRecord::Base

  def pictureimg=(picture_field)
    return if picture_field.blank?
    #self.content_type = picture_field.content_type.chomp
    self.picture = picture_field.read
  end

  def self.save_file(upload)
    begin
      FileUtils.mkdir(upload_path) unless File.directory?(upload_path)

      #书上的案例代码如下，但是老是上传文件不成功，后来简单改为btypes = upload.read即可
      #bytes = upload

      # if upload.kind_of?(StringIO)
      #   upload.rewind
      #   bytes = upload.read
      # end
      bytes = upload.read

      name = upload.original_filename
      File.open(upload_path(name), "wb") { |f| f.write(bytes) }
      File.chmod(0644, upload_path(name) )
    rescue
      raise
    end
  end
  def self.upload_path(file=nil)
    "#{RAILS_ROOT}/public/files/#{file.nil? ? '' : file}"
  end
  


end
