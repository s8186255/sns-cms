class Example::Chapter2Controller < ApplicationController
  def myaction
    @persons = User.find :all
  end
def myresponse

end

end
