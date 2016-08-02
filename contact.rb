require 'pg'
require 'pry'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  class ContactNotFoundError < StandardError
  end

  TABLE = 'contacts'

  @@conn = PG::Connection.open(dbname: 'contacts')

  attr_reader :id
  attr_accessor :name, :email

  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email,id=nil)
    @name = name
    @email = email
    @id = id
  end

  def to_s
    @id.nil? ? "#{name} (#{email})" : "#{id}: #{name} (#{email})"
  end

  def save
    if saved?
      @@conn.exec("UPDATE #{TABLE} SET name='#{name}', email='#{email}' WHERE id=#{id}::int")
    else
      @id = @@conn.exec_params("INSERT INTO #{TABLE} (name, email) VALUES ($1, $2) \
                                RETURNING id;", [name, email])
    end
    self
  end

  def destroy
    @@conn.exec_params("DELETE FROM #{TABLE} WHERE id=$1::int;", [id])
  end

  def saved?
    !!@id
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # select all the contacts from the database using the connection and continue to return
    # an Array of Contact objects
    # @return [Array<Contact>] Array of Contact objects
    def all
      @@conn.exec("SELECT * FROM #{TABLE} ORDER BY id;").map { |contact| instance_from_row(contact) }
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      Contact.new(name,email).save
    end

    # Find the Contact in the database with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id
    def find(id)
      raise ArgumentError, "You must enter a valid ID." if id.nil?
      result = @@conn.exec_params("SELECT * FROM #{TABLE} WHERE id=$1::int;", [id])
      raise ContactNotFoundError, "No contact with ID #{id} found." if result.values.empty?
      instance_from_row(result.first)
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

    private

    def instance_from_row(result)
      Contact.new(result['name'], result['email'], result['id'])
    end

  end
end
