require 'pry'
require 'securerandom'
require 'singleton'

# MailBox
class MailBox
  attr_reader :queue

  def initialize(address)
    @address = address
    @queue = []
  end

  def append(message)
    @queue << message
  end

  def fetch
    message = @queue[0]
    @queue.delete_at(0)

    message
  end
end

# AddressList
class AddressList
  include Singleton

  def initialize
    @actors = {}
  end

  def register(actor)
    @actors[actor.address] = actor
  end

  def find(address)
    @actors[address]
  end
end

class Message
  attr_reader :message, :opts

  def initialize(message, opts)
    @message = message
    @opts = opts
  end
end

# Actor
class Actor
  attr_reader :address, :state, :mail_box

  def initialize(state)
    @state = state
    @address = SecureRandom.uuid
    @mail_box = MailBox.new(@address)

    AddressList.instance.register(self)
  end

  def send(address, message, opts = [])
    actor = AddressList.instance.find(address)
    actor.mail_box.append(Message.new(message, opts))
  end
end

o = Owner.new(0)
dog = Dog.new(:side_by_owner)

o.go(dog)
puts dog.state

class Owner < Actor
  def go(dog)
    send(
      dog.address,
      lambda do |_, receiver, _|
        receiver.update_state(:out_from_owner)
      end
    )
  end

  def come(dog)
    send(
      dog.address,
      lambda do |_, receiver, _|
        receiver.update_state(:side_by_owner)
      end
    )
  end
end

class Dog < Actor
  def update_state(new_state)
    @state = new_state
  end
end
