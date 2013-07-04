require 'hpricot'

class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
  validates :system_user_id, :presence => true

  belongs_to  :system_user
  has_one  :collected_info

  # def sender
  #   SystemUser.find_by_code((CollectedInfo.find_by_submission_id(self.id).vht_code).gsub(/^0*/, ''))
  # end

  def manage_with_xml! xml
    raise Exception.new(%[The new XML submission data processor is still under construction.])
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

  # XXX: Consider this obsolete, even though supported.
  def save *args
    super *args
    # vht 13b3a5a9b46 0653 11/18/2012 2 5 1 4 2 4 5 0 0 2 0 2 1 3 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 18 7 27 23 17 10 39 MT5
    init   = self.pdu.gsub(/^vht\s+/i, '')
    if init =~ /^<sub/ then
      manage_with_xml! init
      return
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
