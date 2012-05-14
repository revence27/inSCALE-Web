class Binary < ActiveRecord::Base
  belongs_to :client
  has_many :jad_fields
  scope :latest, order('created_at DESC').limit(1)

  def [] n
    JadField.where(:binary_id => self.id, :key => n)
  end

  def binary
    self.jar_sha1.unpack('m').first
  end
end
