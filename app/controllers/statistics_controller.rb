class StatisticsController < ApplicationController
  def index
    @subs = CollectedInfo.order('created_at DESC').paginate(:page => request[:page])
  end

  def csv
    @subs = CollectedInfo.order('created_at DESC').paginate(:page => request[:page])
    response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
    response.headers['Content-Disposition'] = %[attachment; filename=#{Time.now.strftime('%d-%B-%Y-%H%Mh')}.csv]
    render 'csv.csv.erb'
  end
end
