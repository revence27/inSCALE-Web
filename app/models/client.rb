class Client < ActiveRecord::Base
  has_many :binaries

  def [] n
    self.binary[n]
  end

  def version
    self.binary.id
  end

  def empty?
    Binary.count < 1
  end

  def binary
    Binary.latest.binary
  end

  def jad
    self.binary.jad_fields.inject([]) do |p, n|
      # TODO: You may need to tweak 'em a bit. Drop 'Version'.
      p + [%[#{n.key}:#{n.value}]]
    end.join("\n")
  end
end
