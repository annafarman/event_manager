require 'csv' #for RUBY CSV
require 'google/apis/civicinfo_v2'
puts 'Event Manager Initialized!'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

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

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
    )

contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])

    begin
        legislators = civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        )
        legislators = legislators.officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end

    puts "#{name} #{zipcode} #{legislators}"
end
