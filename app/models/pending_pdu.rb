class PendingPdu < ActiveRecord::Base
  def self.from_missed_codes!
    dem = MissedCode.all
    dec = dem.count.to_f
    cpt = 0.0
    nic = 0.0
    got = Set.new
    dem.each do |mc|
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
      mc.delete
    end
  end

  def self.from_system_errors!
    dem = SubmissionError.all
    dec = dem.count.to_f
    cpt = 0.0
    nic = 0.0
    got = Set.new
    SubmissionError.all.each do |se|
      if se.pdu then
        mc  = MissedCode.new(pdu: se.pdu, url: se.url, tentative_code: '0000')
        sha = (Digest::SHA1.new << mc.uid).to_s
        cpt = cpt + 1.0
        unless got.member? sha then
          self.create(payload: se.pdu, probable_code: '0000', pdu_uid: sha, submission_path: se.url)
          got << sha
          mc.lazarus_come_forth! do |ci|
            nic = nic + 1.0
            $stderr.write((("\r\r%d:%d %3d%%/%d%%" % [nic.to_i, cpt.to_i, (cpt + dec) * 100.0, (nic / dec) * 100.0]) + " (#{se.tentative_code}): #{sha} #{mc.uid} ...")[0, 75])
            $stderr.flush
          end
        end
        se.delete
      end
    end
  end
end
