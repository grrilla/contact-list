require 'csv'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  class ContactNotFoundError < StandardError
  end

  attr_accessor :name, :email
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email)
    @name = name
    @email = email
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      CSV.read('contacts.csv')
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      highest_id = 0
      Contact.all.each do |contact|
        if contact[0].to_i > highest_id
          highest_id = contact[0].to_i
        end
      end
      new_contact = Contact.new(name,email)
      contact_file = CSV.open('contacts.csv', 'a')
      contact_file << [(highest_id + 1).to_s, new_contact.name, new_contact.email]
      new_contact
    end
    
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      raise ArgumentError, "You must enter a valid ID." if id.nil?
      Contact.all.each do |contact|
        return contact if contact[0] == id
      end
      raise ContactNotFoundError, "No contact with ID #{id} found."
    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      raise ArgumentError, "You must enter a valid search term." if term.nil?
      matches = Array.new
      Contact.all.each do |contact|
        matched_term = false
        contact.each do |value|
          matched_term = true if value.include? term
        end
        matches << contact if matched_term
      end
      raise ContactNotFoundError, "No record containing expression \"#{term}\" found." if matches.empty?
      matches
    end

  end

end
