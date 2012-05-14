class CreateCollectedInfos < ActiveRecord::Migration
  def change
    create_table :collected_infos do |t|
      t.timestamp       :time_sent
      t.string          :vht_code
      t.integer         :male_children
      t.integer         :female_children
      t.integer         :positive_rdt
      t.integer         :negative_rdt
      t.integer         :diarrhoea
      t.integer         :fast_breathing
      t.integer         :fever
      t.integer         :danger_sign
      t.integer         :treated_within_24_hrs
      t.integer         :treated_with_ors
      t.integer         :treated_with_zinc12
      t.integer         :treated_with_zinc1
      t.integer         :treated_with_amoxi_red
      t.integer         :treated_with_amoxi_green
      t.integer         :treated_with_coartem_yellow
      t.integer         :treated_with_coartem_blue
      t.integer         :treated_with_rectal_artus_1
      t.integer         :treated_with_rectal_artus_2
      t.integer         :treated_with_rectal_artus_4
      t.integer         :referred
      t.integer         :died
      t.integer         :male_newborns
      t.integer         :female_newborns
      t.integer         :home_visits_day_1
      t.integer         :home_visits_day_3
      t.integer         :home_visits_day_7
      t.integer         :newborns_with_danger_sign
      t.integer         :newborns_referred
      t.integer         :newborns_yellow_MUAC
      t.integer         :newborns_red_MUAC
      t.integer         :ors_balance
      t.integer         :zinc_balance
      t.integer         :yellow_ACT_balance
      t.integer         :blue_ACT_balance
      t.integer         :red_amoxi_balance
      t.integer         :green_amoxi_balance
      t.integer         :rdt_balance
      t.integer         :rectal_artus_balance
      t.boolean         :gloves_left_mt5
      t.boolean         :muac_tape
      t.integer         :submission_id
      t.timestamps
    end
  end
end
