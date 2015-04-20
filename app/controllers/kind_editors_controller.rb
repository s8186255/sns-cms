class KindEditorsController < ApplicationController
  skip_before_filter :verify_authenticity_token  


  def upload_img
    image_file = Attachment.create :uploaded_data=>params[:imgFile]
    sleep 1
    render :text => %Q'
    <script type="text/javascript">
      parent.KE.plugin["image"].insert("#{params[:id]}","#{image_file.public_filename}","#{params[:imgTitle]}","#{params[:imgWidth]}","#{params[:imgHeight]}","#{params[:imgBorder]}");
    </script>
    '
  end

  def upload_attach
    attach_file = Attachment.create :uploaded_data=>params[:attachment]
    file_type = attach_file.public_filename.scan(/\.([a-zA-Z]+)/).flatten.to_s
    render :text => %Q'
    <script type="text/javascript">
      parent.KE.plugin["accessory"].insert("#{params[:id]}","#{attach_file.public_filename}","#{params[:imgTitle]}","#{file_type}");
    </script>
    '
  end

 
end
