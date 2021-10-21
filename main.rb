require 'pry'
require 'securerandom'

class Actor
  attr_reader :address
  def initialize()
    @address = SecureRandom.uuid
  end
end

a = Actor.new()

binding.pry
