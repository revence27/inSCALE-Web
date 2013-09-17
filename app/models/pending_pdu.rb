class PendingPdu < ActiveRecord::Base
  def self.with_a_shout!
    self.all.each do |pp|
      pp.with_a_shout!
    end
  end

  def with_a_shout! &block
    mc  = MissedCode.new(pdu: self.payload, url: self.submission_path, tentative_code: self.probable_code)
    mc.lazarus_come_forth!(&block)
  end

  def self.from_missed_codes!
    dec = MissedCode.all.count.to_f
    cpt = 0.0
    nic = 0.0
    got = Set.new
    MissedCode.find_in_batches(batch_size: 100) do |batch|
      batch.each do |mc|
        sha = (Digest::SHA1.new << mc.uid).to_s
        cpt = cpt + 1.0
        unless got.member? sha then
          self.create(payload: mc.pdu, probable_code: mc.tentative_code, pdu_uid: sha, submission_path: mc.url)
          mc.lazarus_come_forth! do |ci|
            nic = nic + 1.0
            got << sha
            $stderr.write((("\r\r%d:%d %3d%%/%d%%" % [nic.to_i, cpt.to_i, (cpt / dec) * 100.0, (nic / dec) * 100.0]) + " (#{mc.tentative_code}): #{sha} #{mc.uid} ...")[0, 75])
            $stderr.flush
          end
        end
        mc.delete if got.member? sha
      end
    end
  end

  def self.from_system_errors!
    dem = SubmissionError.all
    dec = dem.count.to_f
    cpt = 0.0
    nic = 0.0
    got = Set.new
    SubmissionError.find_in_batches(batch_size: 100) do |batch|
      batch.each do |se|
        if se.pdu =~ /^vht\s+/ then
          mc  = MissedCode.new(pdu: se.pdu, url: se.url, tentative_code: '0000')
          sha = (Digest::SHA1.new << mc.uid).to_s
          cpt = cpt + 1.0
          unless got.member? sha then
            self.create(payload: se.pdu, probable_code: '0000', pdu_uid: sha, submission_path: se.url)
            got << sha
            mc.lazarus_come_forth! do |ci|
              nic = nic + 1.0
              $stderr.write((("\r\r%d:%d %3d%%/%d%%" % [nic.to_i, cpt.to_i, (cpt / dec) * 100.0, (nic / dec) * 100.0]) + ": #{sha} #{mc.uid} ...")[0, 75])
              $stderr.flush
            end
          end
          se.delete if got.member? sha
        end
      end
    end
  end
end
