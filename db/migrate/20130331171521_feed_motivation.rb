class FeedMotivation < ActiveRecord::Migration
  def up
    File.open(ENV['MOTIVATIONAL'] || 'db/Motivational-SMS.txt') do |fich|
      fich.each_line do |ligne|
        ligne = ligne.strip
        unless ligne.empty? then
          mn1, _, _, _, msg, *_ = ligne.split("\t")
          mot                   = MotivationalMessage.create :month => mn1.strip.to_i, :english => msg.gsub(/^"/, '').gsub(/"$/, '').strip
        end
      end
    end
  end

  def down
    MotivationalMessage.all.each do |mm|
      mm.delete
    end
  end
end
