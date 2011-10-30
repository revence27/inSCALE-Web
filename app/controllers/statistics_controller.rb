class StatisticsController < ApplicationController
  def index
    @subs = Submission.order('created_at DESC').paginate(:page => request[:page])
  end
end
