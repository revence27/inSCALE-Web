class Submission < ActiveRecord::Base
  validates :pdu, :presence => true
  validates :system_user_id, :presence => true

  belongs_to  :system_user
  has_one  :collected_info

  def save *args
    super *args
    pieces = self.pdu.gsub(/^vht\s+/i, '').split(/\s+/)
    cinfo  = CollectedInfo.new(
      :submission_id    => self.id,
      :time_sent        => Time.mktime(1970, 1, 1).localtime + pieces[0].to_i(16),
      :vht_code         => pieces[1],
      :male_children    => pieces[2].to_i,
      :female_children  => pieces[3].to_i,
      :positive_rdt     => pieces[4].to_i,
      :negative_rdt     => pieces[5].to_i,
      :diarrhoea        => pieces[6].to_i,
      :fast_breathing   => pieces[7].to_i,
      :fever            => pieces[8].to_i,
      :danger_sign      => pieces[9].to_i,
      :treated_within_24_hrs  =>  pieces[10].to_i,
      :treated_with_ors       =>  pieces[11].to_i,
      :treated_with_zinc12    =>  pieces[12].to_i,
      :treated_with_zinc1     =>  pieces[13].to_i,
      :treated_with_amoxi_red =>  pieces[14].to_i,
      :treated_with_amoxi_green     =>  pieces[15].to_i,
      :treated_with_coartem_yellow  =>  pieces[16].to_i,
      :treated_with_coartem_blue    =>  pieces[17].to_i,
      :treated_with_rectal_artus_1  =>  pieces[18].to_i,
      :treated_with_rectal_artus_2  =>  pieces[19].to_i,
      :treated_with_rectal_artus_4  =>  pieces[20].to_i,
      :referred           =>  pieces[21].to_i,
      :died               =>  pieces[22].to_i,
      :male_newborns      =>  pieces[23].to_i,
      :female_newborns    =>  pieces[24].to_i,
      :home_visits_day_1  =>  pieces[25].to_i,
      :home_visits_day_3  =>  pieces[26].to_i,
      :home_visits_day_7  =>  pieces[27].to_i,
      :newborns_with_danger_sign  =>  pieces[28].to_i,
      :newborns_referred    =>  pieces[29].to_i,
      :newborns_yellow_MUAC =>  pieces[30].to_i,
      :newborns_red_MUAC    =>  pieces[31].to_i,
      :ors_balance          =>  pieces[32].to_i,
      :zinc_balance         =>  pieces[33].to_i,
      :yellow_ACT_balance   =>  pieces[34].to_i,
      :blue_ACT_balance     =>  pieces[35].to_i,
      :red_amoxi_balance    =>  pieces[36].to_i,
      :green_amoxi_balance  =>  pieces[37].to_i,
      :rdt_balance          =>  pieces[38].to_i,
      :rectal_artus_balance =>  pieces[39].to_i,
      :gloves_left_mt5      =>  pieces[40] == 'MT5',
      :muac_tape            =>  pieces[41] == 'Y'
    )
    cinfo.save
    yield(cinfo) if block_given?
  end
end
