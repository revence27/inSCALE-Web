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
      Thread.new do
        ans = SubmissionsReport.file_dispatch(naming.join(' to ') + (session[:dist] ? " (#{District.find_by_id(session[:dist]).name} District)" : ''), addrs, @subs)
        ans.attachments[naming.join('-') + '.csv'] = ERB.new(File.read('app/views/statistics/csv.csv.erb')).result(binding)
        ans.deliver
      end
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
    return csv_continuation
    start   = Time.mktime(*request[:startat].split('/').reverse).localtime
    finish  = Time.mktime(*request[:endat].split('/').reverse).localtime
    @subs   = CollectedInfo.order('created_at DESC').where(['time_sent >= ?', start]).where(['time_sent < ?', finish])
    # adorn_and_render_csv_response start, finish
    adorn_and_continue_csv_response start, finish
  end

  def adorn_and_continue_csv_response pos
    @batch = CsvBatch.find_by_id(pos)
    if request[:email] and request[:email].length > 2 then
      addrs = request[:email].split(',')
      ans   = SubmissionsReport.file_dispatch(@batch.heading, addrs, @batch)
      ans.attachments[@batch.filename] = ("%s\r\n%s" % [@batch.first_row, @batch.csv_batch_rows.map {|x| x.row}.join("\r\n")])
      ans.deliver
      redirect_to '/data'
    else
      response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
      response.headers['Content-Disposition'] = %[attachment; filename=#{@batch.filename}]
      render(text: "%s\r\n%s" % [@batch.first_row, @batch.csv_batch_rows.map {|x| x.row}.join("\r\n")])
    end
  end

  def csv_continuation
    start   = Time.mktime(*request[:startat].split('/').reverse).localtime
    finish  = Time.mktime(*request[:endat].split('/').reverse).localtime
    them    = CollectedInfo.order('created_at DESC').where(['time_sent >= ?', start]).where(['time_sent < ?', finish])
    total   = request[:total] || them.count
    batsiz  = request[:size] || 250
    curbat  = request[:batch] || 0
    yourid  = request[:bid]
    naming  = [start.strftime('%d-%B'), finish.strftime('%d-%B-%Y')]
    bob     =
      if yourid.nil? then
        b = CsvBatch.create(
          heading: naming.join(' to ') + (session[:dist] ? " (#{District.find_by_id(session[:dist]).name} District)" : ''),
          filename: naming.join('-') + '.csv',
          first_row: '="Submission Date",="VHT Phone Number",="VHT Name",="District",="Sub-County",="Parish",="VHT Code",="Start Date of Report",="End Date of Report",="Male Children",="Female Children",="Number of RDTs Positive",="Number of RDTs Negative",="Number of Children with Diarrhoea",="Number of Children with fast breathing",="Number of Children with fever",="Number of Children with Danger sign",="Number of Children treated within 24 hours",="Number of Children treated with ORS",="Number of Children treated with Zinc 1/2 tablet",="Number of Children treated with Zinc 1 tablet",="Number of Children treated with Amoxicillin red",="Number of Children treated with Amoxicillin green",="Number of Children treated with Coartem yellow",="Number of Children treated with Coartem blue",="Number of Children treated with rectal artesunate",="Number of Children referred",="Number of Children who died",="Number of male newborns",="Number of female newborns",="Number of home visits Day 1",="Number of home visits Day 3",="Number of home visits Day 7",="Number of newborns with danger signs",="Number of newborns referred",="Number of newborns with Yellow MUAC",="Number of newborns with Red MUAC/Oedema",="ORS balance",="Zinc balance",="Yellow ACT balance",="Blue ACT balance",="Red Amoxicillin balance",="Green Amoxicillin balance",="RDT balance",="Rectal Artesunate balance"')
        yourid  = b.id
        b
      else
        CsvBatch.find_by_id(yourid.to_i)
      end
    # startpt = bob.point || (batsiz.to_i * curbat.to_i)
    startpt = [batsiz.to_i * curbat.to_i, bob.point.to_i].max
    if startpt <= total.to_i then
      CollectedInfo.find_in_batches(batch_size: batsiz, start: startpt) do |batch|
        batch.each do |sub|
          sbm = sub.submission
          next unless sbm
          sdr = sbm.system_user
          next unless sdr
          sup = sdr.supervisor.parish
          CsvBatchRow.create(csv_batch_id: yourid.to_i, row: %[="#{sub.created_at }",="#{sdr.number }",="#{sdr.name }",="#{sdr.district.name }",="#{(sdr.sub_county.name rescue 'Unknown sub-country') }",="#{(sdr.parish ? sdr.parish.name : (sup.name rescue sup).to_s) }",="#{sub.vht_code }",="#{sub.start_date }",="#{sub.end_date }",="#{sub.male_children }",="#{sub.female_children }",="#{sub.positive_rdt }",="#{sub.negative_rdt }",="#{sub.diarrhoea }",="#{sub.fast_breathing }",="#{sub.fever }",="#{sub.danger_sign }",="#{sub.treated_within_24_hrs }",="#{sub.treated_with_ors }",="#{sub.treated_with_zinc12 }",="#{sub.treated_with_zinc1 }",="#{sub.treated_with_amoxi_red }",="#{sub.treated_with_amoxi_green }",="#{sub.treated_with_coartem_yellow }",="#{sub.treated_with_coartem_blue }",="#{sub.treated_with_rectal_artus_1 }",="#{sub.referred }",="#{sub.died }",="#{sub.male_newborns }",="#{sub.female_newborns }",="#{sub.home_visits_day_1 }",="#{sub.home_visits_day_3 }",="#{sub.home_visits_day_7 }",="#{sub.newborns_with_danger_sign }",="#{sub.newborns_referred }",="#{sub.newborns_yellow_MUAC }",="#{sub.newborns_red_MUAC }",="#{sub.ors_balance }",="#{sub.zinc_balance }",="#{sub.yellow_ACT_balance }",="#{sub.blue_ACT_balance }",="#{sub.red_amoxi_balance }",="#{sub.green_amoxi_balance }",="#{sub.rdt_balance }",="#{sub.rectal_artus_balance }"]) rescue nil
        end
        path      = ('/system/csv_continuation?total=%d&size=%d&batch=%d&bid=%d&startat=%s&endat=%s&email=%s' % [total, batsiz, curbat.to_i + 1, yourid, request[:startat], request[:endat], request[:email]])
        bob.url   = path
        bob.point = curbat.to_i + 1
        bob.save
        return redirect_to(path)
      end
    else
      return adorn_and_continue_csv_response yourid
    end
  end
end
