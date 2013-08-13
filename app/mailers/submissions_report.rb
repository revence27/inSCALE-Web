class SubmissionsReport < ActionMailer::Base
  default from: "inscale@malariaconsortium.org"

  def file_dispatch sub, dests, subs
    @subs = subs
    @sub  = sub
    dests.each do |dest|
      mail(to: dest, subject: @sub)
    end
  end
end
