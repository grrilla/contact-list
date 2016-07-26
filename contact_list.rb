require_relative 'contact'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList
  
  if ARGV[0]
    case ARGV[0].downcase

      when "list" then
      	counter = 0
        Contact.all.each do |contact|
          print "\n#{contact[0]}: #{contact[1]} (#{contact[2]})"
          counter += 1
        end
        puts "\n---\n#{counter} records found\n\n"
    
      when "new" then
        print "\nEnter the new contact's full name: "
        name = STDIN.gets.chomp
        print "Now the email address associated with this contact: "
        email = STDIN.gets.chomp
        begin
          Contact.create(name,email)
          puts "#{name} was saved successfully.\n\n"
        rescue => e
          puts "#{e.class}: #{e.message}\n\n"
        end
    
      when "show" then
      	begin
          contact = Contact.find(ARGV[1])
          puts "\n#{contact[0]}: #{contact[1]} (#{contact[2]})\n\n"
        rescue => e
          puts "#{e.class}: #{e.message}\n\n"
        end

      when "search" then
        begin
          matches = Contact.search(ARGV[1])
          matches.each do |contact|
            puts "\n#{contact[0]}: #{contact[1]} (#{contact[2]})"
          end
          puts ""
        rescue => e
          puts "#{e.class}: #{e.message}\n\n"
        end        	

    end
  else
  	puts "\nHere is a list of available commands:"
  	puts "    #{"new".ljust(8)}- Create a new contact"
  	puts "    #{"list".ljust(8)}- List all contacts"
  	puts "    #{"show".ljust(8)}- Show a contact"
  	puts "    #{"search".ljust(8)}- Search contacts\n\n"
  end
end
