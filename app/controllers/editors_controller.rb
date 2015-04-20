class EditorsController < ApplicationController
  skip_before_filter :verify_authenticity_token  
  def upload_editor_image
    #Attachment.create :uploaded_data=>params[:imgFile]
    render :text => %Q'
      <script>
        window.parent.LoadIMG(\'/editor/upload/Winter.jpg\')
      </script>
    '
  end

  def upload_editor_attach
  end

end
