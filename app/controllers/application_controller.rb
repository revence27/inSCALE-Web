class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ascertain_logged_in, :except => [:auth, :update, :client_download, :record]

  def auth
    @clients    = Client.all
    @publishers = Publisher.all
    @statmen    = BioStat.all
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
    when 'stat' then
      bst = BioStat.find_by_id request[:stat]
      dig = (Digest::SHA1.new << %[#{bst.sha1_salt}#{request[:password]}]).to_s
      if bst.sha1_pass == dig then
        session[:stat] = bst.id
        return redirect_to(request[:from] || data_path)
      else
        flash[:error]  = 'Access Denied'
      end
    when 'logout' then
      session[:client] = session[:stat] = session[:root] = nil
      flash[:message]  = 'Bye!'
      return redirect_to auth_path
    end
  end

  def ascertain_logged_in
    unless session[:stat] or session[:root] or session[:client] then
      redirect_to auth_path(:from => request.path)
    end
  end
end
