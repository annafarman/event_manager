require 'csv' #for RUBY CSV
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

def clean_phone_number(phone)
    phone = phone.gsub(/\D/, '')
    if phone.length == 11 && phone.start_with?('1')
        phone[1, 10]
    elsif phone.length != 10
        'Phone number is not provided.'
    else
        phone
    end
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

def save_thankyou_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')
    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end

@registration_hour = []
@registration_day = []

def peak_reg_time
    registration_counts = Hash.new(0)   # p registration_counts {}
    @registration_hour.each do |time|
        registration_counts[time] += 1
    end
    # p registration_counts {"10"=>1, "13"=>3, "19"=>2, "11"=>2, "15"=>1, "16"=>3, "17"=>1, "1"=>1, "18"=>1, "21"=>2, "20"=>2}
    peak_hour = registration_counts.select { |time, count|
        count == registration_counts.values.max
    }.keys
    # p peak_hour ["13", "16"]
    puts "Peak registration time(s) are between:  "
    peak_hour.each do |time|
        time = time.to_i
        puts "- #{time}:00 - #{time+1}:00 "
    end
end

def peak_reg_day
    registration_counts = Hash.new(0)
    # p @registration_day
    @registration_day.each do |day|
        registration_counts[day] += 1
    end

    peak_day = registration_counts.select { |day, count| 
        count == registration_counts.values.max
    }.keys

    # p registration_counts
    puts "Most people registered on #{peak_day.join(', ')}."
end

contents = CSV.open(
    'event_attendees.csv', 
    headers: true,
    header_converters: :symbol
    )

template_letter = File.read('form_letter.html')
erb_template = ERB.new template_letter


contents.each do |row|
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])
    phone_num = clean_phone_number(row[:homephone])
    reg_time = row[:regdate].split(' ')

    @registration_hour << reg_time[1].split(':')[0]
    #obtaining the hour only. result: ["10", "13", "13", "19", "11", "15", "16", "17", "1", "16", "18", "21", "11", "13", "20", "19", "21", "16", "20"]
    
    date = Date.strptime(reg_time[0], "%m/%d/%y")
    @registration_day << date.strftime("%A")

    legislators = legislators_by_zipcode(zipcode)
    form_letter = erb_template.result(binding)

    save_thankyou_letter(id, form_letter)

end

peak_reg_time
peak_reg_day

