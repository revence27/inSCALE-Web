class MissedCode < ActiveRecord::Base
  def self.as_hash doc
    (doc / 'v').inject({}) do |p, n|
      p[n['t'].to_sym]  = n.inner_html
      p
    end
  end

  def as_hash
    @xml ||= self.pdu.gsub(/^vht\s+/, '')
    @doc ||= Hpricot::XML(@xml)
    @hsh ||= MissedCode.as_hash(@doc)
  end

  def uid
    hsh     = self.as_hash
    (@guid ||= hsh.keys.sort.inject('') {|p, n| p + "[#{n}:#{hsh[n]}]"})
  end

  def save *args
          return super(*args)

    begin
      if self.pdu_uid.nil? then
        self.pdu_uid = self.uid
      end
    rescue Exception => e
    end
    super *args
  end

  def self.unique!
    MissedCode.all.each do |mc|
      mc.unique!
    end
  end

  def lazarus_come_forth! &block
    user = SystemUser.find_by_code(self.as_hash[:vc])
    unless user.nil? then
      # More-correct: make a POST request to elect.url with `message` being elect.pdu
      subm  = Submission.create pdu: self.pdu, system_user_id: user.id
      subm.manage_with_xml!(@xml, &block)
    end
  end

  def unique!
    seen  = Set.new
    MissedCode.all.each do |mc|
      seen << mc if mc.uid == self.uid
    end
    elect, *reprobate = seen.to_a
    reprobate.each { |soul| soul.delete }
  end
end
