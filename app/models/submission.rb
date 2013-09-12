require 'hpricot'

class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
  validates :system_user_id, :presence => true

  belongs_to  :system_user
  has_one  :collected_info

  # def sender
  #   SystemUser.find_by_code((CollectedInfo.find_by_submission_id(self.id).vht_code).gsub(/^0*/, ''))
  # end

  def as_hash doc
    (doc / 'v').inject({}) do |p, n|
      p[n['t'].to_sym]  = n.inner_html
      p
    end
  end

  def manage_with_xml! xml, &block
    doc    = Hpricot::XML(xml)
    data   = as_hash doc
    stt    = (Time.mktime(1970, 1, 1) + 3.hours) + data[:date].to_i(16)
    sentt  = data[:t]
    sentt  = (sentt.nil? ? stt : (Time.mktime(1970, 1, 1) + 3.hours) + data[:t].to_i(16))
    cinfo  = CollectedInfo.new(
      :submission_id    => self.id,
      :time_sent        => sentt,
      :vht_code         => data[:vc],
      :start_date       => stt,
      :end_date         => stt + 7.days,
      :male_children    => data[:male].to_i,
      :female_children  => data[:fem].to_i,
      :positive_rdt     => data[:rdtp].to_i,
      :negative_rdt     => data[:rdtn].to_i,
      :diarrhoea        => data[:diar].to_i,
      :fast_breathing   => data[:fastb].to_i,
      :fever            => data[:fever].to_i,
      :danger_sign      => data[:danger].to_i,
      :treated_within_24_hrs  =>  data[:treated].to_i,
      :treated_with_ors       =>  data[:ors].to_i,
      :treated_with_zinc12    =>  data[:zinc12].to_i,
      :treated_with_zinc1     =>  data[:zinc].to_i,
      :treated_with_amoxi_red =>  data[:amoxr].to_i,
      :treated_with_amoxi_green     =>  data[:amoxg].to_i,
      :treated_with_coartem_yellow  =>  data[:coary].to_i,
      :treated_with_coartem_blue    =>  data[:coarb].to_i,
      :treated_with_rectal_artus_1  =>  data[:recart].to_i,
      :referred           =>  data[:ref].to_i,
      :died               =>  data[:death].to_i,
      :male_newborns      =>  data[:mnew].to_i,
      :female_newborns    =>  data[:fnew].to_i,
      :home_visits_day_1  =>  data[:hv1].to_i,
      :home_visits_day_3  =>  data[:hv3].to_i,
      :home_visits_day_7  =>  data[:hv7].to_i,
      :newborns_with_danger_sign  =>  data[:newbdanger].to_i,
      :newborns_referred    =>  data[:newbref].to_i,
      :newborns_yellow_MUAC =>  data[:yellow].to_i,
      :newborns_red_MUAC    =>  data[:red].to_i,
      :rectal_artus_balance =>  data[:recartbal].to_i,
      :ors_balance          =>  data[:orsbal].to_i,
      :zinc_balance         =>  data[:zincbal].to_i,
      :yellow_ACT_balance   =>  data[:yactbal].to_i,
      :blue_ACT_balance     =>  data[:bactbal].to_i,
      :red_amoxi_balance    =>  data[:ramoxbal].to_i,
      :green_amoxi_balance  =>  data[:gamoxbal].to_i,
      :rdt_balance          =>  data[:rdtbal].to_i,
      :gloves_left_mt5      =>  data[:glvbal] == 'MT5'
    )
    su  = SystemUser.find_by_code(data[:vc])
    su.last_contribution = Time.now
    UserTag.where('name = ? AND system_user_id = ?', ['dormant', su.id]).each do |ut|
      ut.delete
    end
    su.save
    cinfo.save
    block.call(cinfo) if block
  end

  # XXX: Consider this obsolete, even though supported.
  def save *args, &block
    super *args
    # vht 13b3a5a9b46 0653 11/18/2012 2 5 1 4 2 4 5 0 0 2 0 2 1 3 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 18 7 27 23 17 10 39 MT5
    init   = self.pdu.gsub(/^vht\s+/i, '')
    if init =~ /^<sub/ then
      return manage_with_xml!(init, &block)
    end
    pieces = init.split(/\s+/)
    tpcs   = pieces[2].split(/\D+/)
    stt    = Time.mktime(tpcs[2], tpcs[0], tpcs[1]).localtime
    cinfo  = CollectedInfo.new(
      :submission_id    => self.id,
      :time_sent        => Time.mktime(1970, 1, 1).localtime + (pieces[0].to_i(16) / 1000),
      :vht_code         => pieces[1],
      :start_date       => stt,
      # :end_date         => Time.mktime(* pieces[3].split(/\D+/)).localtime,
      :end_date         => stt + 7.days,
      :male_children    => pieces[3].to_i,
      :female_children  => pieces[4].to_i,
      :positive_rdt     => pieces[5].to_i,
      :negative_rdt     => pieces[6].to_i,
      :diarrhoea        => pieces[7].to_i,
      :fast_breathing   => pieces[8].to_i,
      :fever            => pieces[9].to_i,
      :danger_sign      => pieces[10].to_i,
      :treated_within_24_hrs  =>  pieces[11].to_i,
      :treated_with_ors       =>  pieces[12].to_i,
      :treated_with_zinc12    =>  pieces[13].to_i,
      :treated_with_zinc1     =>  pieces[14].to_i,
      :treated_with_amoxi_red =>  pieces[15].to_i,
      :treated_with_amoxi_green     =>  pieces[16].to_i,
      :treated_with_coartem_yellow  =>  pieces[17].to_i,
      :treated_with_coartem_blue    =>  pieces[18].to_i,
      :treated_with_rectal_artus_1  =>  pieces[19].to_i,
      :referred           =>  pieces[20].to_i,
      :died               =>  pieces[21].to_i,
      :male_newborns      =>  pieces[22].to_i,
      :female_newborns    =>  pieces[23].to_i,
      :home_visits_day_1  =>  pieces[24].to_i,
      :home_visits_day_3  =>  pieces[25].to_i,
      :home_visits_day_7  =>  pieces[26].to_i,
      :newborns_with_danger_sign  =>  pieces[27].to_i,
      :newborns_referred    =>  pieces[28].to_i,
      :newborns_yellow_MUAC =>  pieces[29].to_i,
      :newborns_red_MUAC    =>  pieces[30].to_i,
      :rectal_artus_balance =>  pieces[31].to_i,
      :ors_balance          =>  pieces[32].to_i,
      :zinc_balance         =>  pieces[33].to_i,
      :yellow_ACT_balance   =>  pieces[34].to_i,
      :blue_ACT_balance     =>  pieces[35].to_i,
      :red_amoxi_balance    =>  pieces[36].to_i,
      :green_amoxi_balance  =>  pieces[37].to_i,
      :rdt_balance          =>  pieces[38].to_i,
      :gloves_left_mt5      =>  pieces[39] == 'MT5'
    )
    cinfo.save
    yield(cinfo) if block_given?
  end
end
