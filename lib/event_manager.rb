require 'csv' #for RUBY CSV

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

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
    )

contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode]

    zipcode = clean_zipcode(zipcode)

    puts "#{name} #{zipcode}"
end
