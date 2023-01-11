require "../mdns"
require "socket"

# this is the basis for a full Continuous Multicast DNS Querying service
# this implements a very basic transport layer
class MDNS::Server
  # Usage: `MDNS::Server.new(MDNS::IPv4)`
  def initialize(@address : Socket::IPAddress, buffer_size = 16, loopback = false, hops = 255)
    @socket = UDPSocket.new @address.family
    @socket.reuse_address = true
    @socket.reuse_port = true
    @socket.bind(@address.family.inet? ? Socket::IPAddress::UNSPECIFIED : Socket::IPAddress::UNSPECIFIED6, @address.port)
    @socket.join_group(@address)
    @socket.multicast_loopback = loopback
    @socket.multicast_hops = hops
    @channel = MessageChannel.new(buffer_size)

    spawn { MDNS.monitor(@socket, @channel) }
  end

  getter address : Socket::IPAddress
  getter socket : UDPSocket
  getter channel : MessageChannel

  def close
    channel.close
    socket.close
  end

  def closed?
    channel.closed?
  end

  # receive a mDNS message
  def receive
    channel.receive
  end

  # this is only required if the information is not already in a cache built from
  # the messages being pushed down the channel
  def query
    # build request
    request = MDNS::Message.new
    yield request
    socket.send(request, address)
    nil
  end

  def query(domain : String, type : Type = Type::PTR, klass : RecordClass = RecordClass::Internet)
    query(&.query(domain, type, klass))
  end
end
