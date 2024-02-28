require 'csv' #for RUBY CSV
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'Event Manager Initialized!'

def clean_zipcode(zipcode)
    # if zipcode.nil?
    #     zipcode = '00000'
    # elsif zipcode.length < 5
    #     zipcode = zipcode.rjust(5, '0')
    # elsif zipcode.length > 5
    #     zipcode = zipcode[0..4]
    # else
    #     zipcode
    # end

    zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
        legislators = civic_info.representative_info_by_address(
            address: zip,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials

        # legislators_names = legislators.map do |legislator|
        #     legislator.name
        # end
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end


contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
    )

template_letter = File.read('form_letter.html')
erb_template = ERB.new template_letter


contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)
    # puts "#{name} #{zipcode} #{legislators}"
    # personal_letter = template_letter.gsub('FIRST_NAME', name)
    # personal_letter.gsub!('LEGISLATORS', legislators)

    form_letter = erb_template.result(binding)
    puts form_letter
end


