class StatisticsController < ApplicationController
  before_filter :load_local_vhts

  def load_local_vhts
    @local_vhts = SystemUser.where('district_id = ?', session[:dist]).map {|x| x.code}
  end

  def index
    @subs = CollectedInfo.where('vht_code IN (?)', @local_vhts).order('created_at DESC').paginate(:page => request[:page])
  end

  def adorn_and_render_csv_response tmp = Time.now, unt = Time.now
    response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
    response.headers['Content-Disposition'] = %[attachment; filename=#{tmp.strftime('%d-%B')}-#{unt.strftime('%d-%B-%Y')}.csv]
    render 'csv.csv.erb'
  end

  def csv
    @subs = CollectedInfo.where('vht_code IN (?)', @local_vhts).order('created_at DESC')
    adorn_and_render_csv_response
  end

  def ranged_csv
    start   = Time.mktime(*request[:startat].split('/').reverse).localtime
    finish  = Time.mktime(*request[:endat].split('/').reverse).localtime
    @subs   = CollectedInfo.order('created_at DESC').where(['time_sent >= ?', start]).where(['time_sent < ?', finish])
    adorn_and_render_csv_response start, finish
  end
end
