class Example::Chapter5Controller < ApplicationController
  def index
  end
  def alert_without_rjs
    render :text => "alert('Hello without RJS')",
      :content_type => "text/javascript"
  end
  def alert_with_rjs
    render :update do |page|
      page.alert "Hello from inline RJS"
    end
  end
  def external
  end
  def show_alert
    render :text=>"hh"
  end
  def new
    @entry = Entry.new
  end
  def show
    @reversed_text = params[:text_to_reverse].reverse
    render :layout => false
  end
end
