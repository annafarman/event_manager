puts 'Event Manager Initialized!'

contents = File.read('event_attendees.csv')

# puts contents
# puts File.exist? 'event_attendees.csv'

# Ruby’s String#split allows you to convert a string of text into an array along a particular character. By default when you send the split message to the String without a parameter it will break the string apart along each space " " character. Therefore, we need to specify the comma "," character to separate the columns.

# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#     # puts line
#     columns = line.split(",")
#     # p columns
#     name = columns[2]
#     puts name
# end

#exclude the first row

lines = File.readlines('event_attendees.csv')
lines.each_with_index do |line, index|
    # puts line
    next if index == 0
    columns = line.split(",")
    # p columns
    name = columns[2]
    puts name
end