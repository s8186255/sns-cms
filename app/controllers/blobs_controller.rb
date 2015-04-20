# To change this template, choose Tools | Templates
# and open the template in the editor.

class BlobsController < ApplicationController
  def initialize
    
  end

  def create
    begin
      total = params[:assets].length
      params[:assets].each do |file|
        #render :text=>file.kind_of?(StringIO)
        Blob.save_file(file)
      end
      flash[:notice] = "#{total} files uploaded successfully"
    rescue
      raise
    end
#    redirect_to :action => "index"

  end

  def new

  end
end
