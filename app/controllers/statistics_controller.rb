class StatisticsController < ApplicationController
  def index
    @subs = CollectedInfo.order('created_at DESC').paginate(:page => request[:page])
  end
end
