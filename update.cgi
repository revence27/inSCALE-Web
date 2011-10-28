#!	/usr/bin/env ruby

require 'cgi'
require 'digest/sha1'


def umain args
	cgi = CGI.new
	vsn = (Digest::SHA1.new << (File.stat $0).mtime.to_s).to_s
	cgi.out do
		if cgi['version'].to_f < 1.5 then
			%[UPDATE\x00http://1st.ug/etc/contentment/Contentment.jad]
		elsif cgi['status'] == vsn then
			'OK'
		else
%[PROVIDERS\x00#{vsn}\x008198\x00SMS Media\x002299\x00Scyfy Technologies\x01\
\
0\x03FB8198\x03Facebook via SMS\x03FB {text 140 Your Wall message}\x031\x03Happy Automatic Birthday!\x03Send an automatic birthday greeting to your friends every year, without even having to remember!\x03BD {year In which year was your friend born?} {month In which month was your friend born?} {day On which day?} {phone Your friend's phone number} {bool Should the birthday greetings be sent at midnight on the birthday? (If you choose "No", it will be sent later on at daybreak.)} {data 140 What customised message would you like to send?} {show This is just a demo application from Scyfy Technologies. No message will be sent.} {exit}\x031\x03Support\x03Call Customer Support\x03{call +256718202639}{exit}\
\
\x031\x03Register in Business Directory\x03Do you have a business that you would like to give more visibility? Record it in this business directory.\x03{data The name of the business:} {data What industry is the business engaged in?} {data Describe the business. (This information will be used in searches, so incude all the relevant keywords in your description.)} {data E-Mail address:} {data Post Office address:} {data Location:} {phones Phone numbers to contact for more info:} {data Who should a client ask to speak to, when he/she calls your business' phone numbers?}\
\
\x031\x03Search Business Directory\x03Easily locate any business by searching the business directory.\x03{data Describe the business you would like to find:}\
\
\x031\x03Trading Post\x03Record an item that you would like to sell.\x03{data What do you want to sell?} {data Describe the product (this info will be searched, so include all the relevant keywords):} {number At what price are you selling it?} {data What is the location of your product (where applicable)?} {data Any further notes for potential buyers?} {phones What numbers should be contacted by potential buyers?}\
\
\x031\x03Find Items to Buy\x03If you want to find something to buy, use this application to search for it and locate it easily.\x03{data Describe the item you want to find:}\
\
\x031\x03Discreet Delivery\x03The Discreet Delivery Service allows you to order for items that you do not want to buy yourself. You tell us what you want, and we find it for you, buy it, and deliver it to your chosen location. Discreetly.\x03{data What do you want to have delivered?} {data Where should it be delivered?} {number What is the cost of the item?} {phones What numbers should be called for more information?}\
\
\x031\x03User Details\x03Tell us more about yourself.\x03{data Your name:} {password Your password:} {choice Your%20gender: m:Male:f:Female} {year Year of birth}/{month Month in which you were born}/{day Day of the month on which you were born?}\
]

#	Testing HMIS.


%[PROVIDERS\x00#{vsn}\x002299\x00Scyfy Technologies\x01\
\
0\x03Outpatient Attendance\x03Outpatient attendance totals for the month.\x031 {gdrpair New%20attendance 0-4 years|5 and over} {gdrpair Re-attendance 0-4 years|5 and over} {gdrpair Total%20attendance 0-4 years|5 and over} {gdrpair Referrals%20to%20unit%20(all%20ages) 0-4 years|5 and over} {gdrpair Referrals%20from%20unit%20(all%20ages) 0-4 years|5 and over} {show This is just a demo questionnaire. No message will be sent.} {exit}\
\x03\
0\x03Laboratory Tests\x03Lab test totals for the month.\x032 {gdrpair Malaria%20blood%20smear No. of tests done.|No. Positive} {gdrpair Syphilis%20screening No. of tests done.|No. Positive} {show This is just a demo questionnaire. No message will be sent.} {exit}\
\x03\
0\x03Outpatient Diagnoses\x03Outpatient diagnosis totals for the month.\x033 {gdrpair Acute%20flaccid%20paralysis 0-4 years|5 and over} {gdrpair Cholera 0-4 years|5 and over} {gdrpair Dysentery 0-4 years|5 and over} {gdrpair Meningitis%20(meningococcal) 0-4 years|5 and over} {gdrpair Measles 0-4 years|5 and over} {pair Tetanus%20(neonatal)(0-28%20days%20age) Male|Female} {show This is just a demo questionnaire. No message will be sent.} {exit}\
\x03\
0\x03Antenatal/Postnatal Clinic\x03MCH and FP Activities\x034 {number New ANC attendance} {number ANC re-attendance 4th visit} {number Referrals to unit} {number First dose IPT (IPT1)} {number Second dose IPT (IPT2)} {number Postnatal visits} {number Vit A supplementation (postnatal)} {show This is just a demo questionnaire. No message will be sent.} {exit}\
\x03\
0\x03Child Health\x03MCH and FP Activities\x035 {gdrpair Vit%20A%20supplement%201st%20Dose%20in%20the%20year 0-4 yrs|5-14 yrs} {gdrpair Dewormed%201st%20Dose%20in%20the%20year 0-4 yrs|5-14 yrs} {gdrpair Weight%20below%20bottom%20line 0-4 yrs|5-14 yrs} {gdrpair Total%20weighed 0-4 yrs|5-14 yrs} {show This is just a demo questionnaire. No message will be sent.} {exit}\
\x03\
0\x03Support\x03Call Customer Support\x03{call +256772344681}{exit}\
]



		end
	end
	0
end

exit(umain(ARGV))
