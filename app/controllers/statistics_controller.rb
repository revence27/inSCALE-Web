class StatisticsController < ApplicationController
  def index
    @subs = CollectedInfo.order('created_at DESC').paginate(:page => request[:page])
  end

  def adorn_and_render_csv_response tmp = Time.now
    response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
    response.headers['Content-Disposition'] = %[attachment; filename=#{tmp.strftime('%d-%B-%Y-%H%Mh')}.csv]
    render 'csv.csv.erb'
  end

  def csv
    @subs = CollectedInfo.order('created_at DESC')
    adorn_and_render_csv_response
  end

  def ranged_csv
    start   = Time.mktime(*request[:startat].split('/').reverse).localtime
    finish  = Time.mktime(*request[:endat].split('/').reverse).localtime
    @subs = CollectedInfo.order('created_at DESC').where(['start_date >= ?', start]).where(['start_date < ?', finish])
    adorn_and_render_csv_response start
  end
end
