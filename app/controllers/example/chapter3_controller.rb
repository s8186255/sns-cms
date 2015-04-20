class Example::Chapter3Controller < ApplicationController
  def index
    @person = User.find :first
  end
  def get_time
    sleep(1)
    render :text => Time.now
  end
  def repeat
    render :text => params.inspect
  end
  def add_task
    render :partal=>'list'
  end
  def reverse
    # @reversed_text = params[:text_to_reverse]
    #render :text=>params[:text_to_reverse].reverse
    body_text = request.raw_post || request.query_string

    total_words = body_text.split(/\s+/).length
    total_chars = body_text.length
    render :text=>total_chars
    #    if ( total_chars >= 100)
    #      render :text => "<p class=\"error\">Warning: Length exceeded!
    #                        (You have #{total_chars} characters; #{total_words}
    #                        words.)</p>"
    #    else
    #      render :nothing => true
    #    end
  

  end

end
