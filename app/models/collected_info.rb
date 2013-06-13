class CollectedInfo < ActiveRecord::Base
  belongs_to :submission

  def pdu
    self.submission.pdu
  end

  def self.csvheader
    %["Submission Date","VHT Phone Number","VHT Name","Parish","VHT Code","Start Date of Report","End Date of Report","Male Children","Female Children","Number of RDTs Positive","Number of RDTs Negative","Number of Children with Diarrhoea","Number of Children with fast breathing","Number of Children with fever","Number of Children with Danger sign","Number of Children treated within 24 hours","Number of Children treated with ORS","Number of Children treated with Zinc 1/2 tablet","Number of Children treated with Zinc 1 tablet","Number of Children treated with Amoxicillin red","Number of Children treated with Amoxicillin green","Number of Children treated with Coartem yellow","Number of Children treated with Coartem blue","Number of Children treated with rectal artesunate","Number of Children referred","Number of Children who died","Number of male newborns","Number of female newborns","Number of home visits Day 1","Number of home visits Day 3","Number of home visits Day 7","Number of newborns with danger signs","Number of newborns referred","Number of newborns with Yellow MUAC","Number of newborns with Red MUAC/Oedema","ORS balance","Zinc balance","Yellow ACT balance","Blue ACT balance","Red Amoxicillin balance","Green Amoxicillin balance","RDT balance","Rectal Artesunate balance","Gloves left","MUAC tape present?"]
  end

  def self.tableheader
    %[
            <thead>
              <tr>
                <th>Submission Date</th>
                <th>VHT Phone Number</th>
                <th>VHT Name</th>
                <th>Parish</th>
                <th>VHT Code</th>
                <th>Start Date of Report</th>
                <th>End Date of Report</th>
                <th>Male Children</th>
                <th>Female Children</th>
                <th>Number of RDTs Positive</th>
                <th>Number of RDTs Negative</th>
                <th>Number of Children with Diarrhoea</th>
                <th>Number of Children with fast breathing</th>
                <th>Number of Children with fever</th>
                <th>Number of Children with Danger sign</th>
                <th>Number of Children treated within 24 hours</th>
                <th>Number of Children treated with ORS</th>
                <th>Number of Children treated with Zinc &frac12; tablet</th>
                <th>Number of Children treated with Zinc 1 tablet</th>
                <th>Number of Children treated with Amoxicillin red</th>
                <th>Number of Children treated with Amoxicillin green</th>
                <th>Number of Children treated with Coartem yellow</th>
                <th>Number of Children treated with Coartem blue</th>
                <th>Number of Children treated with rectal artesunate</th>
                <th>Number of Children referred</th>
                <th>Number of Children who died</th>
                <th>Number of male newborns</th>
                <th>Number of female newborns</th>
                <th>Number of home visits Day 1</th>
                <th>Number of home visits Day 3</th>
                <th>Number of home visits Day 7</th>
                <th>Number of newborns with danger signs</th>
                <th>Number of newborns referred</th>
                <th>Number of newborns with Yellow MUAC</th>
                <th>Number of newborns with Red MUAC/&OElig;dema</th>
                <th>ORS balance</th>
                <th>Zinc balance</th>
                <th>Yellow ACT balance</th>
                <th>Blue ACT balance</th>
                <th>Red Amoxicillin balance</th>
                <th>Green Amoxicillin balance</th>
                <th>RDT balance</th>
                <th>Rectal Artesunate balance</th>
                <th>Gloves left</th>
                <th>MUAC tape present?</th>
              </tr>
            </thead>
    ]
  end
end
