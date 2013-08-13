class StatisticsController < ApplicationController
  before_filter :load_local_vhts

  def load_local_vhts
    @local_vhts = SystemUser.where('district_id = ?', session[:dist]).map {|x| x.code}
  end

  def index
    @subs = (session[:dist] ? CollectedInfo.where('vht_code IN (?)', @local_vhts) : CollectedInfo).order('created_at DESC').paginate(:page => request[:page])
  end

  def adorn_and_render_csv_response tmp = Time.now, unt = Time.now
    naming  = [tmp.strftime('%d-%B'), unt.strftime('%d-%B-%Y')]
    if request[:email] and request[:email].length > 2 then
      addrs = request[:email].split(',')
      ans = SubmissionsReport.file_dispatch(naming.join(' to ') + (session[:dist] ? " (#{District.find_by_id(session[:dist]).name} District)" : ''), addrs, @subs)
      ans.attachments[naming.join('-') + '.csv'] = ERB.new(File.read('app/views/statistics/csv.csv.erb')).result(binding)
      ans.deliver
      redirect_to request.referer
    else
      response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
      response.headers['Content-Disposition'] = %[attachment; filename=#{naming.join('-')}.csv]
      render 'csv.csv.erb'
    end
  end

  def csv
    @subs = (session[:dist] ? CollectedInfo.where('vht_code IN (?)', @local_vhts) : CollectedInfo).order('created_at DESC')
    adorn_and_render_csv_response
  end

  def ranged_csv
    start   = Time.mktime(*request[:startat].split('/').reverse).localtime
    finish  = Time.mktime(*request[:endat].split('/').reverse).localtime
    @subs   = CollectedInfo.order('created_at DESC').where(['time_sent >= ?', start]).where(['time_sent < ?', finish])
    adorn_and_render_csv_response start, finish
  end
end
