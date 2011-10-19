class ContentmentController < ApplicationController
  def index
    if session[:client] then
      return redirect_to questions_path
    end
  end

  def update
  end

  def qns
  end

  def auth
    if session[:client] then
      return redirect_to questions_path
    end
  end
end
