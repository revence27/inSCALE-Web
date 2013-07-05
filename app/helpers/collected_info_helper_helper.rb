module CollectedInfoHelperHelper
  def ci_table_header
    capture_haml do
      haml_tag :thead do
        haml_tag :tr do
          haml_tag :th, 'Submission Date'
          haml_tag :th, 'VHT Phone Number'
          haml_tag :th, 'VHT Name'
          haml_tag :th, 'Parish'
          haml_tag :th, 'VHT Code'
          haml_tag :th, 'Start Date of Report'
          haml_tag :th, 'End Date of Report'
          haml_tag :th, 'Male Children'
          haml_tag :th, 'Female Children'
          haml_tag :th, 'Number of RDTs Positive'
          haml_tag :th, 'Number of RDTs Negative'
          haml_tag :th, 'Number of Children with Diarrhoea'
          haml_tag :th, 'Number of Children with fast breathing'
          haml_tag :th, 'Number of Children with fever'
          haml_tag :th, 'Number of Children with Danger sign'
          haml_tag :th, 'Number of Children treated within 24 hours'
          haml_tag :th, 'Number of Children treated with ORS'
          haml_tag :th, 'Number of Children treated with Zinc &frac12; tablet'.html_safe
          haml_tag :th, 'Number of Children treated with Zinc 1 tablet'
          haml_tag :th, 'Number of Children treated with Amoxicillin red'
          haml_tag :th, 'Number of Children treated with Amoxicillin green'
          haml_tag :th, 'Number of Children treated with Coartem yellow'
          haml_tag :th, 'Number of Children treated with Coartem blue'
          haml_tag :th, 'Number of Children treated with rectal artesunate'
          # Number of Children treated with rectal artesunate 2 capsules
          # Number of Children treated with rectal artesunate 4 capsules
          haml_tag :th, 'Number of Children referred'
          haml_tag :th, 'Number of Children who died'
          haml_tag :th, 'Number of male newborns'
          haml_tag :th, 'Number of female newborns'
          haml_tag :th, 'Number of home visits Day 1'
          haml_tag :th, 'Number of home visits Day 3'
          haml_tag :th, 'Number of home visits Day 7'
          haml_tag :th, 'Number of newborns with danger signs'
          haml_tag :th, 'Number of newborns referred'
          haml_tag :th, 'Number of newborns with Yellow MUAC'
          haml_tag :th, 'Number of newborns with Red MUAC/&OElig;dema'.html_safe
          haml_tag :th, 'ORS balance'
          haml_tag :th, 'Zinc balance'
          haml_tag :th, 'Yellow ACT balance'
          haml_tag :th, 'Blue ACT balance'
          haml_tag :th, 'Red Amoxicillin balance'
          haml_tag :th, 'Green Amoxicillin balance'
          haml_tag :th, 'RDT balance'
          haml_tag :th, 'Rectal Artesunate balance'
          # haml_tag :th, 'Gloves left'
          # haml_tag :th, 'MUAC tape present?'
        end
      end
    end
  end

  def ci_table_row sub, sbm
    sdr = sbm.system_user
    sup = sdr.supervisor.parish
    capture_haml do
      haml_tag(:tr, {:class => (sub.died.zero? ? '' : 'skel ')}) do
        # haml_tag :td, sub.time_sent
        haml_tag :td, sub.created_at
        haml_tag :td, sdr.number
        haml_tag :td, sdr.name
        haml_tag :td, (sup ? sup.name : '')
        haml_tag :td, sub.vht_code
        haml_tag :td, sub.start_date
        haml_tag :td, sub.end_date
        haml_tag :td, sub.male_children
        haml_tag :td, sub.female_children
        haml_tag :td, sub.positive_rdt
        haml_tag :td, sub.negative_rdt
        haml_tag :td, sub.diarrhoea
        haml_tag :td, sub.fast_breathing
        haml_tag :td, sub.fever
        haml_tag :td, sub.danger_sign
        haml_tag :td, sub.treated_within_24_hrs
        haml_tag :td, sub.treated_with_ors
        haml_tag :td, sub.treated_with_zinc12
        haml_tag :td, sub.treated_with_zinc1
        haml_tag :td, sub.treated_with_amoxi_red
        haml_tag :td, sub.treated_with_amoxi_green
        haml_tag :td, sub.treated_with_coartem_yellow
        haml_tag :td, sub.treated_with_coartem_blue
        haml_tag :td, sub.treated_with_rectal_artus_1
        # %td #{sub.treated_with_rectal_artus_2}
        # %td #{sub.treated_with_rectal_artus_4}
        haml_tag :td, sub.referred
        haml_tag :td, sub.died
        haml_tag :td, sub.male_newborns
        haml_tag :td, sub.female_newborns
        haml_tag :td, sub.home_visits_day_1
        haml_tag :td, sub.home_visits_day_3
        haml_tag :td, sub.home_visits_day_7
        haml_tag :td, sub.newborns_with_danger_sign
        haml_tag :td, sub.newborns_referred
        haml_tag :td, sub.newborns_yellow_MUAC
        haml_tag :td, sub.newborns_red_MUAC
        haml_tag :td, sub.ors_balance
        haml_tag :td, sub.zinc_balance
        haml_tag :td, sub.yellow_ACT_balance
        haml_tag :td, sub.blue_ACT_balance
        haml_tag :td, sub.red_amoxi_balance
        haml_tag :td, sub.green_amoxi_balance
        haml_tag :td, sub.rdt_balance
        haml_tag :td, sub.rectal_artus_balance
      end
    end
  rescue Exception => e
    ''
  end
end
