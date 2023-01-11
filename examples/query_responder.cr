require "../src/mdns"

# usage:
# export IP_ADDRESS=127.0.0.1
# export DOMAIN_NAMES=myservice.local,otherservice.local
# crystal ./examples/query_responder.cr

# Then in another terminal window:
# ping myservice.local
# output => 127.0.0.1

DOMAINS = ENV["DOMAIN_NAMES"]?.try(&.split(',')) || [] of String
IP_ADDR = ENV["IP_ADDRESS"]? || "127.0.0.1"

puts "Monitoring for #{DOMAINS}..."

server = MDNS::Server.new(MDNS::IPv4)
loop do
  break if server.closed?
  address, message = server.receive

  log(message, address)

  # TTL should be no longer than 10 seconds for unicast requests
  ttl = address.port == 5353 ? 5.minutes : 10.seconds

  # we then respond to queries
  if message.query?
    # only look for IPv4 queries
    domains = message.queries.compact_map do |query|
      query.domain_name if query.type.a?
    end
    responses = [] of MDNS::Resource

    # IPv4 addresses are represented as 4 bytes
    bytes = Bytes.new(4)
    IP_ADDR.split(".").each_with_index { |component, index| bytes[index] = component.to_u8 }

    # process a query here
    (domains & DOMAINS).each do |domain|
      puts "found matching record: #{domain}"
      response = MDNS::Resource.new
      response.domain_name = domain
      response.ttl = ttl
      response.type = :a # A record or IPv4
      response.data = bytes
      responses << response
    end

    if responses.size > 0
      puts "responding to: #{responses.map(&.domain_name).join(", ")} with #{IP_ADDR}"
      message.is_response = true
      message.authoritative_answer = true
      message.answers = responses

      # check if port was 5353 then use multicast.
      # otherwise send a unicast to the source address
      if address.port == 5353
        server.socket.send(message, MDNS::IPv4)
      else
        server.socket.send(message, address)
      end
    end

    puts "\n\n\n"
  end
end

def log(message, address)
  # This code prints the details of the message
  puts Time.utc.to_s("%X")
  puts "QUERY: #{message.queries.map(&.domain_name).join(",")}"
  puts "QUERY Type: #{message.queries.first?.try &.type} from #{address}"
  if message.response?
    puts "ANSWERS:"
    puts message.answers.map { |answer|
      String.build do |str|
        str << answer.domain_name
        str << " => (#{answer.type}) "
        str << answer.payload.inspect
      end
    }.join("\n")
  end
end
