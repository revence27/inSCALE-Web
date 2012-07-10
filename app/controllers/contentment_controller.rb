require 'net/http'

VERSION_START_TIME = Time.mktime 2011, 7, 27

class ContentmentController < ApplicationController
  before_filter :select_client

  def select_client
    @client = Client.find_by_id(session[:client]) if session[:client]
  end

  def index
    @pubs = Publisher.order('name ASC')
  end

  def inbound
    request[:data] = request[:message]
    self.record
  end

  def record
    uid = 1
    cod = request[:data].match /vht\s+(\S+)\s+(\S+)/i
    usr = SystemUser.where('LOWER(code) = ?', [cod[2].downcase]).first
    uid = usr.id if usr
    sub = Submission.new :pdu => request[:data],
              :system_user_id => uid,
              :actual_time    => Time.mktime(1970, 1, 1).localtime + (cod[1].to_i(16) / 1000)
    unless sub.valid? then
      return render :text => 'FAILED'
    end
    sub.save do |info|
      supervisor_alert info
      sender_response info
    end
    render :text => 'OK'
  end

  def supervisor_alert info
    vht = info.submission.system_user
    sup = vht.supervisor
    [
      [
        (info.treated_with_amoxi_red + info.treated_with_amoxi_green) > info.fast_breathing,
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is over-treating with Amoxicillin and needs supervision in when to use antibiotics.]
      ],
      [
        (info.treated_with_amoxi_red + info.treated_with_amoxi_green) < info.fast_breathing,
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is under-treating for fast breathing and needs supervision in when to use antibiotics.]
      ],
      [
        (info.treated_with_coartem_yellow + info.treated_with_coartem_blue) > info.positive_rdt,
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is over-treating with ACT and needs supervision in when to use antimalarials.]
      ],
      [
        (info.treated_with_coartem_yellow + info.treated_with_coartem_blue) < info.positive_rdt,
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is under-treating malaria in children positive on RDT and needs supervision in when to use antimalarials.]
      ],
      [
        (info.diarrhoea > info.treated_with_ors) || (info.diarrhoea > (info.treated_with_zinc12 + info.treated_with_zinc1)),
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is under-treating diarrhoea and needs supervision in when to use ORS and zinc.]
      ],
      [
        info.danger_sign < info.referred,
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is not referring all children with danger signs and needs supervision in when to refer.]
      ],
      [
        # info.fever > ((info.positive_rdt + info.negative_rdt) + 5),
        info.fever > (info.positive_rdt + info.negative_rdt),
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is not testing all children with fever for malaria and needs supervision in when to do an RDT.]
      ],
      [
        (info.newborns_with_danger_sign > (info.newborns_referred + 5)),
        %[Greetings, #{sup.name}. Your supervision is helpful to VHTs. #{vht.name} is not referring all newborns with danger signs and needs supervision in when to refer newborn babies.]
      ],
      [
        info.ors_balance < 6,
        %[Greetings, #{sup.name}. #{vht.name} is low on ORS and will soon need more supplies to treat diarrhoea.]
      ],
      [
        info.zinc_balance < 51,
        %[Greetings, #{sup.name}. #{vht.name} is low on zinc and will soon need more supplies to treat diarrhoea.]
      ],
      [
        (info.yellow_ACT_balance < 6) || (info.blue_ACT_balance < 6),
        %[Greetings, #{sup.name}. #{vht.name} is low on ACTs and will soon need more supplies to treat malaria.]
      ],
      [
        (info.red_amoxi_balance < 6) || (info.green_amoxi_balance < 6),
        %[Greetings, #{sup.name}. #{vht.name} is low on Amoxicillin and will soon need more supplies to treat pneumonia.]
      ],
      [
        info.rdt_balance < 6,
        %[Greetings, #{sup.name}. #{vht.name} is low on RDTs and will soon need more supplies to test for malaria.]
      ],
      [
        info.rectal_artus_balance < 6,
        %[Greetings, #{sup.name}. #{vht.name} is low on rectal artesunate and will soon need more supplies to start treatment and refer severe malaria.]
      ],
      [
        !info.gloves_left_mt5,
        %[Greetings, #{sup.name}. #{vht.name} is low on gloves and will soon need more supplies to conduct RDTs and insert rectal artesunate.]
      ],
      [
        # CollectedInfo.order('time_sent DESC').limit(4).inject(0) do |p, n|
        CollectedInfo.order('end_date DESC').where(['LOWER(vht_code) = ? AND end_date IS NOT ?', vht.code.downcase, nil]).limit(4).inject(0) do |p, n|
          p + n.male_children + n.female_children
        end < 1,
        %[Greetings, #{sup.name}. #{vht.name} has not seen any children in the last one month. Please make contact and find out why.]
      ]
    ].each do |cond|
      if cond[0] then
        Feedback.create :message => cond[1], :number => sup.number, :sender => vht.number
      end
    end
    self.send_messages false
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
    prm = CollectedInfo.order('time_sent ASC').where(['LOWER(vht_code) = ?', sysu.code.downcase]).first
    # msg = ans.gsub('[##]', (info.male_children + info.female_children).to_s).gsub('[###]', CollectedInfo.order('end_date DESC').limit(4).inject(0) do |p, n|
    msg = ans.gsub('[##]', (info.male_children + info.female_children).to_s).gsub('[###]', CollectedInfo.where(['LOWER(vht_code) = ?', sysu.code.downcase]).where(['end_date IS NOT ?', nil]).order('end_date DESC').limit(4).inject(0) do |p, n|
      p + n.male_children + n.female_children
    end.to_s).gsub('[name]', sysu.name || sysu.code).gsub('[month]', (prm.start_date ? prm.start_date : prm.time_sent).strftime('%B %Y'))
    Feedback.create :message => msg, :number => sysu.number
    self.send_messages false
    nil
  end

  def monthly
    # TODO.
  end

  def weekly
    SystemUser.all.each do |su|
      # t2 = su.submissions.order('actual_time DESC').first.actual_time
      t2 = su.submissions.order('end_date DESC').first.actual_time
      if (Time.now - t2) > 518399 then
        Feedback.create :message => %[#{su.name or %[Hello #{su.code}]}, remember to submit your report for Sunday to Saturday last week.], :number => su.number
      end
    end
    self.send_messages false
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
    if bin.jar_sha1 == request[:version]
      group   = Application.where(:client_id => clt.id)
      apps    = group.order('created_at ASC')
      latest  = group.order('updated_at DESC').first.updated_at
      publat  = Publisher.order('updated_at DESC').first.updated_at
      return render :text => 'OK' if apps.empty?
      newid   = ([latest, publat].max - VERSION_START_TIME).to_i
      if newid.to_s == request[:status] then
        render :text => 'OK'
      else
        pubs  = Publisher.where(['id IN (?)', Set.new(apps.map {|a| a.publisher_id})])
        sorter = pubs.inject([{}, 0]) do |p, n|
          p[0][n.id] = p.last
          [p.first, p.last + 1]
        end.first
        publist = pubs.map {|pub| %[\x00#{pub.address}\x00#{pub.name}]}
        applist = apps.map do |app|
          [
            sorter[app.publisher_id],
            app.name,
            app.description,
            app.code
          ].join("\x03")
        end.join("\x03")
        ans = %[PROVIDERS\x00#{newid}#{publist}\x01#{applist}]
        render :text => ans
      end
    else
      render :text => %[UPDATE\x00] + client_download_path(:version => bin.jar_sha1, :format => 'jad', :only_path => false)
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
          dest << tag.system_user.number
        end
      end
    end
    dest.each do |d|
      Feedback.create :sender => request[:sender],
                     :message => request[:message],
                      :number => d
    end
    self.send_messages false
    nil
  end

  def send_messages red = true
    Feedback.where(:sent_on => nil).order('created_at ASC').each do |msg|
      url = %[http://#{request[:gateway] || 'smgw2'}.yo.co.ug:9100/sendsms?ybsacctno=#{CGI.escape(request[:username] || '1000291359')}&password=#{CGI.escape(request[:password] || 'password')}&origin=#{CGI.escape(msg.sender || 'inSCALE')}&sms_content=#{CGI.escape(msg.message.to_s)}&destinations=#{CGI.escape(msg.number.to_s)}&nostore=#{request[:nostore] || 0}]
      begin
        ans = URI.unescape(Net::HTTP.get(URI.parse(url)))
        rsp = ans.split('&').inject({}) do |p, n|
          cle, val  = n.split('=', 2)
          p[cle] = CGI.unescape(val)
          p
        end
        msg.system_response = rsp['ybs_autocreate_status'] + ': ' + rsp['ybs_autocreate_message']
        msg.sent_on         = Time.now
        msg.save
      rescue Exception => e
        $stderr.puts url, e.inspect, e.backtrace
        File.open('/tmp/mamanze.txt', 'w') {|f| f.puts url, e.inspect, e.backtrace }
      end
    end
    redirect_to feedback_path if red
  end

  def users
    if request[:userid] then
      @user  = SystemUser.find_by_id(request[:userid])
      @subs  = @user.submissions.order('created_at DESC').paginate(:page => request[:page])
    end
    @users  = @client.system_users.paginate(:page => request[:page])
    @sups   = Supervisor.order('name ASC')
  end

  def tags
    if request[:name] then
      tags    = UserTag.where(:name => request[:name]).select('system_user_id')
      @users  = SystemUser.where(['id IN (?)', tags.map {|x| x.system_user_id}]).paginate(:page => request[:page])
    else
      @tags   = UserTag.select('DISTINCT name AS name').order('name ASC').paginate(:page => request[:page])
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
end
