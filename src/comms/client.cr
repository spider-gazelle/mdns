require "../mdns"
require "socket"

module MDNS
  DEFAULT_WAIT_TIME = 2.seconds

  alias MessageChannel = Channel(Tuple(Socket::IPAddress, MDNS::Message))

  # you can configure the query in the provided block
  def self.one_shot(wait : Time::Span = DEFAULT_WAIT_TIME, family : Socket::Family = Socket::Family::INET)
    # build request
    request = MDNS::Message.new
    yield request
    request.queries.each(&.unicast_response = true)

    # prepare to receive data
    channel = MessageChannel.new
    socket = UDPSocket.new family
    socket.bind(family.inet? ? Socket::IPAddress::UNSPECIFIED : Socket::IPAddress::UNSPECIFIED6, 0)

    begin
      spawn { MDNS.monitor(socket, channel) }

      # make the request
      socket.send(request, family.inet? ? MDNS::IPv4 : MDNS::IPv6)

      # grab results
      responses = [] of Tuple(Socket::IPAddress, MDNS::Message)
      loop do
        select
        when size_address = channel.receive
          responses << size_address
        when timeout(wait)
          break
        end
      end
      responses
    ensure
      # clean up
      channel.close
      socket.close
    end
  end

  def self.one_shot(domain : String, wait : Time::Span = DEFAULT_WAIT_TIME, type : Type = Type::PTR, klass : RecordClass = RecordClass::Internet, family : Socket::Family = Socket::Family::INET)
    one_shot(wait, family, &.query(domain, type, klass, unicast_response: true))
  end

  protected def self.monitor(socket, channel : MessageChannel)
    # https://tools.ietf.org/html/rfc6762#section-17
    buffer = Bytes.new(9000)
    loop do
      break if socket.closed? || channel.closed?
      size, address = socket.receive(buffer)
      break if size == 0

      # The original `io` is required for decompressing the domain names strings
      # hence why we make a clone of the buffer and set `original_io`
      io = IO::Memory.new(buffer[0...size].clone)
      response = io.read_bytes(MDNS::Message).set_io(io)
      channel.send({address, response})
    end
  rescue IO::Error
  ensure
    # clean up
    channel.close
    socket.close
  end
end
