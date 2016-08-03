require_relative 'setup'
require_relative 'contact'
require 'pry'

class ContactList

  if ARGV[0]
    case ARGV[0].downcase
      when "list"
        Contact.all.each { |contact| print "\n#{contact.to_s}" }
        puts "\n---\n#{Contact.count} records found\n\n"

      when "new"
        begin
          print "\nEnter the new contact's full name: "
          name = STDIN.gets.chomp
          print "Now the email address associated with this contact: "
          email = STDIN.gets.chomp
          new_contact = Contact.create(name: name, email: email)
          puts "#{new_contact.name} was saved successfully at index #{new_contact.id}.\n\n"
        rescue => e
          puts "#{e}: #{e.message}"
        end

      when "show"
        begin
          contact = Contact.find(ARGV[1])
          puts "\n#{contact.to_s}\n\n"
        rescue => e
          puts "#{e}: #{e.message}"
        end

      when "search"
        matches = Contact.where("name LIKE :term OR email LIKE :term", {term: "%" + ARGV[1] + "%"})
        matches.each { |contact| puts "\n#{contact.to_s}" }
        puts ""

      when "update"
        begin
          contact = Contact.find(ARGV[1])
          puts "\nEditing --> #{contact.to_s}\n\n"
          print "Enter contact's updated name: "
          new_name = STDIN.gets.chomp
          print "Enter contact's updated email: "
          new_email = STDIN.gets.chomp
          contact.update(name: new_name, email: new_email)
        rescue => e
          puts "#{e}: #{e.message}"
        end

      when "destroy"
        begin
          Contact.find(ARGV[1]).destroy
          puts "Contact at ID #{ARGV[1]} removed from database."
        rescue => e
          puts "#{e}: #{e.message}"
        end

      else
        puts "\n#{ARGV[0]} is not a valid command.\nTo view a list of available commands," \
              + " run the program again without any arguments.\n\n"
    end
  else
  	puts "\nHere is a list of available commands:"
  	puts "    #{"new".ljust(8)}- Create a new contact"
  	puts "    #{"list".ljust(8)}- List all contacts"
  	puts "    #{"show".ljust(8)}- Show a contact"
  	puts "    #{"search".ljust(8)}- Search contacts"
    puts "    #{"update".ljust(8)}- Update a contact"
    puts "    #{"destroy".ljust(8)}- Delete a contact\n\n"
  end
end
