require 'csv'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  class ContactNotFoundError < StandardError
  end

  attr_reader :name, :email
  attr_accessor :id

  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email,id=nil)
    @name = name
    @email = email
    @id = id
  end

  def to_s
    @id.nil? ? "#{@name} (#{@email})" : "#{@id}: #{@name} (#{@email})"
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      all_contacts = Array.new
      CSV.read('contacts.csv').each do |contact|
        all_contacts << Contact.new(contact[1],contact[2],contact[0])
      end
      all_contacts
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      highest_id = 0
      Contact.all.each do |contact|
        if contact.id.to_i > highest_id
          highest_id = contact.id.to_i
        end
      end
      new_contact = Contact.new(name,email,highest_id + 1)
      contact_file = CSV.open('contacts.csv', 'a')
      contact_file << [new_contact.id.to_s, new_contact.name, new_contact.email]
      new_contact
    end

    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      raise ArgumentError, "You must enter a valid ID." if id.nil?
      contact = Contact.all.find { |contact| contact.id == id }
      raise ContactNotFoundError, "No contact with ID #{id} found." if contact.nil?
      contact
    end

    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      raise ArgumentError, "You must enter a valid search term." if term.nil?
      matches = Contact.all.select do |contact|
        [contact.id, contact.name, contact.email].any? { |attr| attr.include? term }
      end
      raise ContactNotFoundError, "No record containing expression \"#{term}\" found." if matches.empty?
      matches
    end
  end
end
