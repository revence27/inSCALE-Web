require 'hpricot'
require 'net/http'
require 'open-uri'
require 'thread'

DESIGNATED_PASSWORD = 'quiconquecroitenlui'
VERSION_START_TIME  = Time.mktime 2011, 7, 27

class ContentmentController < ApplicationController
  before_filter :select_client, :except => [:inbound, :qc]
  skip_before_filter :verify_authenticity_token, :only => [:inbound, :quality_control]

  def new_bug_report
    BugReport.create :url => params[:url], :description => params[:descr], :contact => params[:contact]
    redirect_to system_health_path
  end

  def system_health
    @reports  = BugReport.order('created_at DESC').paginate(:page => params[:page])
    @missed   = MissedCode.order('created_at DESC').paginate(:page => params[:code])
    @suberr   = SubmissionError.order('created_at DESC').paginate(:page => params[:subm])
  end

  def sms_gateway_is_broken str
    str.gsub(/^(\+)?256/, '0')
  end

  def select_client
    @client = Client.find_by_id(session[:client]) if session[:client]
  end

  def index
    @pubs = Publisher.order('name ASC')
  end

  def inbound
    begin
      request[:data] = request[:message]
      return self.record
    rescue Exception => e
      ans = SubmissionError.create(:url => request.url, :pdu => request[:data], :message => e.message, :backtrace => ([e.inspect] + e.backtrace).join("\n"))
      raise e
      return render(:status => 500, :text => e.message)
    end
  end

  def periodic
    @tasks  = PeriodicTask.order('last_successful ASC')
  end

  def periodic_send
    them  = []
    rqid  = request[:identity]
    if request[:identity] then
      them << PeriodicTask.find_by_identity(rqid)
    else
      them  = PeriodicTask.where(%[last_successful + ((seconds_period || ' SECONDS') :: INTERVAL) > ?], Time.now)
    end
    them.each do |it|
      # Thread.new do
      #   sleep(10 + rand(5))
        open(it.running_url + '?password=' + DESIGNATED_PASSWORD)
      # end
    end
    redirect_to periodic_path
  end

  def create_task
    dl    = request[:delete]
    if dl == 'Delete' then
      per = PeriodicTask.find_by_identity(request[:tid])
      per.delete
      redirect_to periodic_path
      return
    end
    tn    = request[:name]
    id    = request[:tid]
    ru    = request[:url]
    dy    = request[:days].to_i
    secs  = dy * (60 * 60 * 24)
    per   = PeriodicTask.create :task_name => tn, :identity => id, :running_url => ru, :seconds_period => secs
    per.last_successful = (Time.now - secs.seconds + 1.second)
    per.save
    redirect_to periodic_path
  end

  def roll_into_hash doc
    ans = (doc / 'v').inject({}) do |p, n|
      p[n['t'].to_sym] = n.inner_html
      p
    end
  end

  def quality_control
    ans = SubmissionError.create(:url => request[:position] || request.url, :pdu => request[:version], :message => request[:message], :backtrace => request[:backtrace] || 'Phone app sent no backtrace.')
    render :text => 'OK'
  end

  def record_xml! xml
    doc   = Hpricot::XML xml.gsub(/^vht\s+/, '')
    data  = roll_into_hash doc
    usr = SystemUser.where('code = ?', [data[:vc]]).first
    unless usr then
      MissedCode.create :pdu => request[:data], :tentative_code => data[:vc], :url => request.url
      return render(:status => 404, :text => %[This VHT code (#{data[:vc]}) is unknown.])
    end
    sub = Submission.new :pdu => request[:data],
              :system_user_id => usr.id,
              :actual_time    => (Time.mktime(1970, 1, 1) + 3.hours) + ((data[:date].to_i(16) / 1000))
    unless sub.valid? then
      return render(:status => 402, :text => 'FAILED')
    end
    gosp  = 'Successful submission to the server.'
    sub.save do |info|
      # supervisor_alert info
      gosp  =
      begin
        sender_response(info).message
      rescue Exception => e
        gosp
      end
      # send_messages false
    end
    # lf  = usr.latest_feedback
    return render(:status => 200, :text => gosp)
  end

  def record
    begin
      uid = 1
      cod = request[:data].match /vht\s+(\S+)\s+(\S+)/i
      if $1 =~ /<sub/ then
        return record_xml!(request[:data])
      end
      usr = SystemUser.where('code = ?', [cod[2]]).first
      unless usr then
        usr = SystemUser.where('code = ?', [cod[2].downcase]).first
        unless usr then
          MissedCode.create :pdu => request[:data], :tentative_code => cod[2], :url => request.url
          return render(:status => 404, :text => %[This VHT code (#{cod[2]}) is unknown.])
        end
      end
      sub = Submission.new :pdu => request[:data],
                :system_user_id => usr.id,
                :actual_time    => Time.mktime(1970, 1, 1).localtime + (cod[1].to_i(16) / 1000)
      unless sub.valid? then
        return render(:status => 402, :text => 'FAILED')
      end
      gosp  = 'Successful submission to the server.'
      sub.save do |info|
        # supervisor_alert info
        gosp  = sender_response(info).message
        # send_messages false
      end
      # lf  = usr.latest_feedback
      return render(:status => 200, :text => gosp)
    rescue Exception => e
      ans = SubmissionError.create(:url => request.url, :pdu => request[:data], :message => e.message, :backtrace => ([e.inspect] + e.backtrace).join("\n"))
      raise e
      return render(:status => 500, :text => e.message)
    end
  end

  def supervisor_alert info
    return self.send_messages(false)



    vht = info.submission.system_user
    sup = vht.supervisor
    [
      [
        (info.treated_with_amoxi_red + info.treated_with_amoxi_green) > info.fast_breathing,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is over-treating with Amoxicillin and needs supervision in when to use antibiotics.]
      ],
      [
        (info.treated_with_amoxi_red + info.treated_with_amoxi_green) < info.fast_breathing,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is under-treating for fast breathing and needs supervision in when to use antibiotics.]
      ],
      [
        (info.treated_with_coartem_yellow + info.treated_with_coartem_blue) > info.positive_rdt,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is over-treating with ACT and needs supervision in when to use antimalarials.]
      ],
      [
        (info.treated_with_coartem_yellow + info.treated_with_coartem_blue) < info.positive_rdt,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is under-treating malaria in children positive on RDT and needs supervision in when to use antimalarials.]
      ],
      [
        (info.diarrhoea > info.treated_with_ors) || (info.diarrhoea > (info.treated_with_zinc12 + info.treated_with_zinc1)),
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is under-treating diarrhoea and needs supervision in when to use ORS and zinc.]
      ],
      [
        # info.danger_sign < info.referred,
        info.danger_sign > info.referred,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is not referring all children with danger signs and needs supervision in when to refer.]
      ],
      [
        # info.fever > ((info.positive_rdt + info.negative_rdt) + 5),
        info.fever > (info.positive_rdt + info.negative_rdt),
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is not testing all children with fever for malaria and needs supervision in when to do an RDT.]
      ],
      [
        # (info.newborns_with_danger_sign > (info.newborns_referred + 5)),
        info.newborns_with_danger_sign > info.newborns_referred,
        %[Greetings! Your supervision is helpful to VHTs. #{vht.name} is not referring all newborns with danger signs and needs supervision in when to refer newborn babies.]
      ],
      [
        info.ors_balance < 6,
        %[Greetings! #{vht.name} is low on ORS and will soon need more supplies to treat diarrhoea.]
      ],
      [
        info.zinc_balance < 51,
        %[Greetings! #{vht.name} is low on zinc and will soon need more supplies to treat diarrhoea.]
      ],
      [
        (info.yellow_ACT_balance < 6) || (info.blue_ACT_balance < 6),
        %[Greetings! #{vht.name} is low on ACTs and will soon need more supplies to treat malaria.]
      ],
      [
        (info.red_amoxi_balance < 6) || (info.green_amoxi_balance < 6),
        %[Greetings! #{vht.name} is low on Amoxicillin and will soon need more supplies to treat pneumonia.]
      ],
      [
        info.rdt_balance < 6,
        %[Greetings! #{vht.name} is low on RDTs and will soon need more supplies to test for malaria.]
      ],
      [
        info.rectal_artus_balance < 6,
        %[Greetings! #{vht.name} is low on rectal artesunate and will soon need more supplies to start treatment and refer severe malaria.]
      ],
      [
        !info.gloves_left_mt5,
        %[Greetings! #{vht.name} is low on gloves and will soon need more supplies to conduct RDTs and insert rectal artesunate.]
      ],
      [
        # CollectedInfo.order('time_sent DESC').limit(4).inject(0) do |p, n|

        # TODO.
        false || (CollectedInfo.order('end_date DESC').where(['vht_code = ? AND end_date IS NOT ?', vht.code, nil]).limit(4).inject(0) do |p, n|
          p + n.male_children + n.female_children
        end < 1),

        %[Greetings! #{vht.name} has not seen any children in the last one month. Please make contact and find out why.]
      ]
    ].each do |cond|
      if cond[0] then
        Feedback.create :message => cond[1], :tag => 'supervisor alert', :number => sup.number, :sender => sms_gateway_is_broken(vht.number)
      end
    end
    # self.send_messages false
    nil
  end

  def sender_response info
    aujd  = Time.now
    week  = ((((aujd - Time.mktime(aujd.year, 1, 1)).to_i / (24.0 * 60.0 * 60.0))) / 7.0).ceil
    resp  = VhtResponse.find_by_week week
    sysu  = info.submission.system_user
    ans   =
    if resp then
      tent  = if (info.male_children + info.female_children) > 0 then
                resp.many_kids
              else
                resp.no_kids
              end
    else
      %[Thank you, [name], for your submission!]
    end
    prm = CollectedInfo.order('time_sent ASC').where(['vht_code = ?', sysu.code]).first
    # msg = ans.gsub('[##]', (info.male_children + info.female_children).to_s).gsub('[###]', CollectedInfo.order('end_date DESC').limit(4).inject(0) do |p, n|
    msg = ans.gsub('[##]', (info.male_children + info.female_children).to_s).gsub('[###]', CollectedInfo.where(['vht_code = ?', sysu.code]).where(['end_date IS NOT ?', nil]).order('end_date DESC').limit(4).inject(0) do |p, n|
      p + n.male_children + n.female_children
    end.to_s).gsub('[name]', sysu.name || sysu.code).gsub('[month]', (prm.start_date ? prm.start_date : prm.time_sent).strftime('%B %Y'))
    rsp = Feedback.create :message => msg, :tag => 'submission response', :number => sysu.number
    self.send_messages false
    rsp
  end

  def monthly
    unless request[:password] == DESIGNATED_PASSWORD then
      render :text => 'PASSWORD MISSING', :status => 403
      return
    end
    mon = Time.now.month
    msg = MotivationalMessage.where(:month => mon).first
    return render(:text => 'No recorded messages to send.') unless msg
    SystemUser.all.each do |su|
      Feedback.create :message => msg.english, :tag => 'monthly motivation', :number => su.number
    end
    self.send_messages false
    render :text => "Motivational messages sent for month #{mon}", :status => 200
    pt = PeriodicTask.get_by_identity('motivation')
    pt.last_successful = Time.now
    pt.save
    nil
  end

  def weekly
    unless request[:password] == DESIGNATED_PASSWORD then
      render :text => 'PASSWORD MISSING', :status => 403
      return
    end
    ans = []
    SystemUser.all.each do |su|
      t2 = su.submissions.order('actual_time DESC').first.actual_time rescue nil
      unless t2
        ans << "No submissions from #{su.code} (#{su.name})."
        next
      end
      if (Time.now - t2) > 518399 then
        m = %[#{su.name or %[Hello #{su.code}]}, remember to submit your report for Sunday to Saturday last week.]
        Feedback.create :message => m, :number => su.number, :tag => 'weekly'
        ans << m
      end
    end
    self.send_messages false
    render :text => %[Reminders sent for this week #{Time.now.localtime}.\n\n#{ans.join("\n")}], :status => 200
    pt = PeriodicTask.find_by_identity('remindvhts')
    pt.last_successful = Time.now
    pt.save
    nil
  end

  def application
    @app = Application.where(:id => request[:id], :client_id => session[:client]).first
    unless @app then
      redirect_to home_url
    end
  end

  def update_application
    app = Application.find_by_id request[:id]
    app.update_attributes :name         => request[:name],
                          :description  => request[:descr],
                          :code         => request[:code]
    unless app.valid? then
      flash[:error] = 'Provide the name, description, and application code.'
    end
    redirect_to application_path(:id => app.id)
  end

  def delete_application
    Application.delete request[:id]
    redirect_to home_path
  end

  def chooser
    redirect_to home_url
  end

  def publisher
    if request[:id] then
      @pub  = Publisher.find_by_id request[:id]
    else
      @pubs = Publisher.order('name ASC')
    end
  end

  def delete_publisher
    pub = Publisher.delete request[:id]
    redirect_to home_path
  end

  def create_publisher
    pub = Publisher.create(   :name => request[:name],
                           :address => request[:address])
    if pub.valid? then
      redirect_to(publisher_path(:id => pub.id))
    else
      flash[:error] = %[Provide both name and address.]
      redirect_to publisher_path
    end
  end

  def update_publisher
    pub = Publisher.find_by_id request[:id]
    pub.update_attributes :name => request[:name], :address => request[:address]
    redirect_to publisher_path(:id => pub.id)
  end

  def destroy_app
    app = Application.where :id         => request[:app],
                            :client_id  => session[:client]
    app.destroy request[:app]
    redirect_to home_path
  end

  def create_app
    pub = Publisher.find_by_id request[:publisher]
    app = Application.create :name        => request[:name],
                             :description => request[:descr],
                             :code        => request[:code]
    pub.applications << app
    pub.save
    @client.applications << app
    @client.save
    redirect_to home_path
  end

  def upload_client
    unless request[:jar] and request[:jad] then
      flash[:error] = 'Upload a JAR file and its JAD file.'
      return redirect_to clients_path
    end
    dat = request[:jar].read
    bin = Binary.new :release_note => request[:descr],
                     :jar_b64      => [dat].pack('m'),
                     :jar_sha1     => (Digest::SHA1.new << dat).to_s,
                     :client_id    => session[:client] || request[:client] || 1
    bin.save
    request[:jad].read.each_line do |line|
      key, val = line.strip.split ':', 2
      JadField.create(:key => key, :value => val, :binary_id => bin.id)
    end
    UserTag.where('name = ?', ['client-updated']).each {|ut| ut.delete  }
    UserTag.where('name = ?', ['questionnaire-updated']).each {|ut| ut.delete  }
    redirect_to clients_path
  end

  def clients
    @clients = Client.where(:id => session[:client]).order 'name ASC'
  end

  def client_download
    bin = Binary.find_by_jar_sha1(request[:version])
    return render :text => '?' unless bin
    if request[:format] == 'jad' then
      jads  = JadField.where :binary_id => bin.id
      rez   = {#  'MIDlet-Version' => '2.' + bin.id.to_s,
               'MIDlet-Jar-SHA1'  => bin.jar_sha1,
               'MIDlet-Creation-Date'  => bin.created_at.strftime('%d%b%Y'),
               'MIDlet-Jar-URL'   => client_download_path(:format => 'jar', :only_path => false)}
      jads.each do |jad|
        rez[jad.key] ||= jad.value.strip
      end
      ans = rez.collect {|k, v| [k, v].join(': ')}.join("\r\n")
      render :text => ans, :content_type => 'text/vnd.sun.j2me.app-descriptor'
    else
      render :text => bin.jar_b64.unpack('m').first, :content_type => 'application/java-archive'
    end
  end

  def update
    clt = Client.find_by_code request[:code]
    return render(:text => 'OK') if clt.binaries.empty?
    bin = Binary.where(:client_id => clt.id).order('created_at DESC').first
    if bin.jar_sha1 == request[:version] then
      if request[:vht] then
        sysu = SystemUser.find_by_code(request[:vht])
        if sysu then
          sysu.latest_client = request[:version]
          sysu.save
          UserTag.create(:name => 'client-updated', :system_user_id => sysu.id) unless UserTag.where(:system_user_id => sysu.id, :name => 'client-updated').first
        end
      end
      group   = Application.where(:client_id => clt.id)
      apps    = group.order('created_at ASC')
      latest  = group.order('updated_at DESC').first.updated_at
      publat  = Publisher.order('updated_at DESC').first.updated_at
      return render :text => 'OK' if apps.empty?
      newid   = ([latest, publat].max - VERSION_START_TIME).to_i
      if newid.to_s == request[:status] then
        if request[:vht] then
          sysu = SystemUser.find_by_code(request[:vht])
          UserTag.create(:name => 'questionnaire-updated', :system_user_id => sysu.id) if sysu and not UserTag.where(:system_user_id => sysu.id, :name => 'questionnaire-updated').first
        end
        render :text => 'OK'
      else
        pubs  = Publisher.where(['id IN (?)', Set.new(apps.map {|a| a.publisher_id})])
        sorter = pubs.inject([{}, 0]) do |p, n|
          p[0][n.id] = p.last
          [p.first, p.last + 1]
        end.first
        publist = pubs.map {|pub| %[\x00#{pub.address}\x00#{pub.name}]}
        applist = apps.map do |app|
          # [
          #   sorter[app.publisher_id],
          #   app.name,
          #   app.description,
          #   app.code
          # ].join("\x03")
          # %[<app id="#{app.name}">#{app.code}</app>]
          app.code
        end.join('')
        # ans = %[PROVIDERS\x00#{newid}#{publist}\x01#{applist}]
        ans = %[<update v="#{newid}">#{applist}</update>]
        render :text => ans
      end
    else
      render :text => %[<upgrade href="] + client_download_path(:version => bin.jar_sha1, :format => 'jad', :only_path => false) + %[" />]
    end
  end

  def feedback
    @feedback = Feedback.order('created_at DESC').paginate(:page => params[:page])
  end

  def messaging
    return unless request[:message] and request[:sender]
    dest  = Set.new
    request[:recip].split(',').each do |num|
      if num.strip =~ /\d{9,}/ then
        dest << num.strip
      else
        UserTag.where(:name => num.strip).each do |tag|
          begin
            dest << tag.system_user.number
          rescue Exception => e
            $stderr.puts [tag.inspect, tag.system_user.inspect, e.inspect]
          end
        end
      end
    end
    if request[:recip] =~ /!/ then
      SystemUser.all.each do |su|
        dest << su.number
      end
      request[:recip] = '?,' + request[:recip]
    end
    if request[:recip] =~ /\?/ then
      Supervisor.all.each do |su|
        dest << su.number
      end
    end
    dest.each do |d|
      Feedback.create :sender => sms_gateway_is_broken(request[:sender]),
                     :message => request[:message],
                      :number => d
    end
    self.send_messages false
    nil
  end

  def send_messages red = true
    kyu = Queue.new
    Thread.new(kyu) do |qyu|
      while true
        got = qyu.pop
        break unless got
        url, fin  = got
        begin
          ans = URI.unescape(Net::HTTP.get(URI.parse(url)))
          rsp = ans.split('&').inject({}) do |p, n|
            cle, val  = n.split('=', 2)
            p[cle] = CGI.unescape(val)
            p
          end
          fin.call rsp
        rescue Exception => e
          $stderr.puts url, e.inspect, e.backtrace
          begin
            File.open('/tmp/sendtracker.log', 'w+') {|f| f.puts(Time.now, url, e.inspect, e.backtrace, "===" * 8, "\n\n\n\n") }
          rescue Exception => e
            # Killing you softly.
          end
        end
      end
    end
    Feedback.where(:sent_on => nil).order('created_at ASC').each do |msg|
      url = %[http://#{request[:gateway] || 'smgw1'}.yo.co.ug:9100/sendsms?ybsacctno=#{CGI.escape(request[:username] || '1000291359')}&password=#{CGI.escape(request[:password] || 'password')}&origin=#{CGI.escape(msg.sender || 'inSCALE')}&sms_content=#{CGI.escape(msg.message.to_s)}&destinations=#{CGI.escape(msg.number.to_s)}&nostore=#{request[:nostore] || 0}]
      kyu << [url, proc do |rsp|
        msg.system_response = rsp['ybs_autocreate_status'] + ': ' + rsp['ybs_autocreate_message']
        msg.sent_on         = Time.now
        msg.save
      end]
    end
    kyu << nil
    redirect_to feedback_path if red
  end

  def sups_update
    @sup  = Supervisor.find_by_id(request[:id])
  end

  def sups_change
    @sup        = Supervisor.find_by_id(request[:id])
    @sup.name   = request[:name]
    @sup.number = request[:number]
    @sup.save
    redirect_to(sups_update_path(@sup))
  end

  def users_update
    @user   = SystemUser.find_by_id(request[:id])
    @sups   = Supervisor.order('name ASC')
    @dists  = District.order('name ASC')
  end

  def users_change
    @user = SystemUser.find_by_id(request[:id])
    @user.name          = request[:name]
    @user.number        = request[:number]
    @user.code          = request[:code]
    @user.sort_code     = (request[:code].to_i || 0)
    @user.supervisor_id = request[:supervisor]
    @user.district_id   = request[:district]
    @user.save
    redirect_to(users_update_path(@user))
  end

  def supervisors
    @sup  = Supervisor.find_by_id(request[:supid])
  end

  def users
    if request[:userid] then
      @user = SystemUser.find_by_id(request[:userid])
      subs  = @user.submissions
      subs  = request[:submission].nil? ? subs : subs.where('id = ?', [request[:submission]])
      @subs = subs.order('created_at DESC').paginate(:page => request[:page])
    end
    # @users  = @client.system_users.order('code ASC').paginate(:page => request[:page])
    @users  = @client.system_users.order('sort_code ASC').paginate(:page => request[:page])
    @sups   = Supervisor.order('name ASC').paginate(:page => request[:spage])
  end

  def vht_motivators
    @motivators = MotivationalMessage.order('month ASC')
    render 'motivational_messages'
  end

  def vht_responses
    @responses  = VhtResponse.order('week ASC')
  end

  def vht_motivator_change
    @motivator  = MotivationalMessage.find_by_id(request[:id])
    render 'motivator_change'
  end

  def vht_response_change
    @response = VhtResponse.find_by_id(request[:id])
  end

  def vht_motivator_changer
    @motivator          = MotivationalMessage.find_by_id(request[:id])
    @motivator.english  = request[:english]
    @motivator.save
    redirect_to motivator_change_path(:id => @motivator.id)
  end

  def vht_response_changer
    @response = VhtResponse.find_by_id(request[:id])
    @response.no_kids   = request[:nokids]
    @response.many_kids = request[:manykids]
    @response.save
    redirect_to response_change_path(:id => @response.id)
  end

  # TODO: Make pagination work with the below.
  def tags
    if request[:name] then
      tags    = UserTag.where(:name => request[:name]).select('system_user_id')
      @users  = SystemUser.where(['id IN (?)', tags.map {|x| x.system_user_id}])  # .paginate(:page => request[:page])  # COUNT seems broken in will_paginate
    else
      @tags   = UserTag.select('DISTINCT name AS name').order('name ASC') #.paginate(:page => request[:page]) # COUNT doesn't seem to work well for now.
    end
  end

  def create_tag
    usr = SystemUser.find_by_id request[:id]
    tag = nil
    tag = UserTag.find_by_name request[:name].capitalize
    tag = UserTag.create :name => request[:name].capitalize unless tag
    return redirect_to(users_path(usr)) unless tag.valid?
    usr.user_tags << tag
    usr.save
    redirect_to users_path(usr)
  end

  def delete_tag
    usr = SystemUser.find_by_id request[:id]
    tag = nil
    tag = UserTag.where(:name => request[:name].capitalize,
              :system_user_id => usr.id).first
    return redirect_to(users_path(usr)) unless tag
    tag.destroy
    redirect_to users_path(usr)
  end

  def create_user
    if request[:supervisor] == '' then
      sup = Supervisor.create :name => request[:name],
                            :number => request[:number]
      sup.save
      redirect_to request.referer
    else
      usr = SystemUser.create :name => request[:name],
                            :number => request[:number],
                         :client_id => @client.id,
                              :code => request[:code],
                         :sort_code => (request[:code].to_i || 0),
                     :supervisor_id => request[:supervisor]
      usr.save
      unless usr.valid? then
        flash[:error] = %[Provide both name and number for the user.]
        return redirect_to(request.referrer || users_path)
      end
      pcs = request[:tags].split(',')
      pcs.each do |pc|
        if pc.strip != '' then
          tag = UserTag.create :name => pc.strip.capitalize
          usr.user_tags << tag
        end
      end
      usr.save
      redirect_to users_path(usr)
    end
  end

  def delete_user
    usr = SystemUser.find_by_id request[:id]
    usr.destroy
    redirect_to users_path
  end

  def delete_supervisor
    usr = Supervisor.find_by_id request[:id]
    usr.destroy
    redirect_to users_path
  end

  def download_feedbacks
    startat   = Time.mktime(*request[:startat].split('/').reverse).localtime
    endat     = Time.mktime(*request[:endat].split('/').reverse).localtime
    @feedback = Feedback.order('created_at DESC').where(['created_at >= ?', startat]).where(['created_at < ?', endat])
    response.headers['Content-Type'] = %[text/csv; encoding=UTF-8]
    response.headers['Content-Disposition'] = %[attachment; filename=#{endat.strftime('%d-%B-%Y-%H%Mh')}.csv]
    render 'download_feedbacks.csv.erb'
  end

  def locations
    @dists  = District.order('name ASC')
    # @pars   = Parish.order('name ASC')
    # @vills  = Village.order('name ASC')
  end

  def district
    @dist = District.find_by_id(request[:id])
  end

  def update_bio_pass
    dist  = District.find_by_id(request[:dist])
    dist.password = request[:password]
    dist.email    = request[:email]
    dist.save
    redirect_to request.referer
  end

  def mails
    # @biostat  = AdminAddress.biostat
    # @admins   = AdminAddress.admins
    @admins = AdminAddress.all
  end

  def add_mail
    AdminAddress.create(:address => request[:address], :name => request[:name], :latest => Time.now, :biostat => request[:biostat] == 'biostat')
    redirect_to mails_path
  end

  def delete_mail
    AdminAddress.find_by_id(request[:id]).delete
    redirect_to mails_path
  end

  def admins
    if request[:oldpass].to_s != '' then
      oldpass = (Digest::SHA1.new << %[#{@client.sha1_salt}#{request[:oldpass]}]).to_s
      if @client.sha1_pass == oldpass then
        if request[:newpass] != '' then
          @client.sha1_pass = (Digest::SHA1.new << %[#{@client.sha1_salt}#{request[:newpass]}]).to_s
        end
        if request[:oldpass] != '' then
          bstat           = BioStat.first
          bstat.sha1_pass = (Digest::SHA1.new << %[#{bstat.sha1_salt}#{request[:biopass]}]).to_s
          bstat.save
        end
        @client.save
      else
        flash[:error] = 'Passwords do not match.'
      end
      redirect_to admins_path
    end
  end

  def search
    return unless request[:q]
    @users  = @client.system_users.where([
            'code = ? OR number = ? OR code = ? OR number = ? OR code = ? OR number = ?',
            request[:q].strip,
            request[:q].strip,
            request[:q].strip.gsub(/^0/, ''),
            request[:q].strip.gsub(/^\+/, ''),
      '0' + request[:q].strip,
      '+' + request[:q].strip
    ]).order('sort_code ASC').paginate(:page => request[:page])
  end
end
