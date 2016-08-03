require 'active_record'

class Contact < ActiveRecord::Base

  def to_s
    "#{id}: #{name} (#{email})"
  end

end
