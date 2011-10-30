VERSION_START_TIME = Time.mktime 2011, 7, 27

class ContentmentController < ApplicationController
  before_filter :ascertain_logged_in, :except => :auth

  def auth
    case request[:who]
    when 'root' then
      root  = RootAccount.order('updated_at DESC').first
      dig   = (Digest::SHA1.new << %[#{root.sha1_salt}#{request[:password]}]).to_s
      if root.sha1_pass == dig then
        session[:root] = 'root'
        return redirect_to(request[:from] || home_path)
      else
        flash[:error]  = 'Access Denied'
      end
    when 'client' then
      clt = Client.find_by_id request[:client]
      dig = (Digest::SHA1.new << %[#{clt.sha1_salt}#{request[:password]}]).to_s
      if clt.sha1_pass == dig then
        session[:client] = clt.id
        return redirect_to(request[:from] || home_path)
      else
        flash[:error]  = 'Access Denied'
      end
    when 'logout' then
      session[:client] = session[:root] = nil
      flash[:message]  = 'Bye!'
      return redirect_to auth_path
    else
      @clients    = Client.all
      @publishers = Publisher.all
    end
  end

  def ascertain_logged_in
    unless session[:root] or session[:client] then
      redirect_to auth_path(:from => request.path)
    else
      # redirect_to home_path
    end
  end

  def index
    @pubs = Publisher.order('name ASC')
  end

  def record
    sub = Submission.create :pdu    => request[:data]
    unless sub.valid? then
      return render :text => 'FAILED'
    end
    # TODO: This is where more-specific storage goes.
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
    clt = Client.find_by_id session[:client]
    clt.applications << app
    clt.save
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
    request[:jad].read.each_line do |line|
      key, val = line.strip.split ':', 2
      bin.jad_fields << JadField.new(:key => key, :value => val)
    end
    bin.save
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
      rez   = {'MIDlet-Version' => bin.jar_sha1,
               'MIDlet-Jar-URL' => %[#{request.scheme}://#{request.host}:#{request.port}#{client_download_path(:format => 'jar')}]}
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
      return render :text => 'OK' if apps.empty?
      newid   = (latest - VERSION_START_TIME).to_i
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
      render :text => %[UPDATE\x00#{request.scheme}://#{request.host}:#{request.port}#{client_download_path(:version => bin.jar_sha1, :format => 'jad')}]
    end
  end
end
