# Crystal Lang mDNS Support

[![Build Status](https://travis-ci.com/spider-gazelle/mdns.svg?branch=master)](https://travis-ci.com/github/spider-gazelle/mdns)

* Discover services using DNS-SD

DNS-SD is used where there might be multiple devices implementing a service.

* Lookup devices using mDNS

mDNS is used to find the IP address of device, like a Raspberry Pi

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mDNS:
       github: spider-gazelle/mdns
   ```

2. Run `shards install`


## Single Shot usage

As described in [the rfc](https://tools.ietf.org/html/rfc6762#section-5.1)


### Simple DNS-SD query

To perform a simple query for a service on the network

```crystal

require "mdns"

# Look up homekit devices on the network
results = MDNS.one_shot "_hap._tcp.local"

results.each do |(address, _io_memory, response)|
  address # => Socket::IPAddress
  response # => MDNS::Message

  response.is_response # => true
  response.authoritative_answer # => true / false
  response.response_code # => ResponseCode::NoError
  response.answer_count # => 1
  response.answers # => Array(MDNS::Resource)
end

```

### Multiple service queries

In a single request

```crystal

# Look up homekit devices and hubs on the network
results = MDNS.one_shot do |message|
  message.query "_hap._tcp.local"
  message.query "_homekit._tcp.local"
end

# You will need to inspect the answers to differentiate between devices and hubs
results.each do |(address, io_memory, response)|
  is_hap = false
  is_kit = false

  response.answers.each do |answer|
    # NOTE:: when extracting the domain name the whole raw response is required
    # due to domain name compression: https://tools.ietf.org/html/rfc1035#section-4.1.4
    domain_name = answer.domain_name(io_memory)

    if domain_name == "_hap._tcp.local"
      is_hap = true
    elsif domain_name == "_homekit._tcp.local"
      is_kit = true
    end
  end
end

```

### mDNS query

If we are looking for the IP address of a device for instance.

```crystal

# We're requesting the IPv4 address of the phone (A record)
# We could also do a multi-request and get the IPv6 address too (AAAA record)
results = MDNS.one_shot "Steves-iPhone.local", type: MDNS::Type::A

if address_response = results.first?
  # NOTE:: the `_address` here is the device that responded, it might not be an
  # an authoritative answer (i.e. something replying on behalf of the device)
  # so extract the IP address from the payload (mDNS only, for DNS-SD use the `_address`)
  _address, _io_memory, response = address_response

  response.answers[0].address # => "192.168.40.150"
end

```


## Continuous Multicast DNS Querying

This is only the most basic of servers implementing the transport layer.
It could definitely be used as the basis for a DNS cache as described by the RFC

```crystal

require "mdns"

server = MDNS::Server.new(MDNS::IPv4)
loop do
  break if server.closed?
  address, io_memory, message = server.receive

  if message.query?
    # process a query here
  else
    # process responses here
  end

  # This code prints the details of the message
  puts Time.utc.to_s("%X")
  puts "QUERY:"
  puts message.queries.map(&.domain_name(io_memory)).join("\n")
  puts "ANSWERS:"
  puts message.answers.map { |answer|
    String.build do |str|
      str << answer.domain_name(io_memory)
      str << " => "
      case answer.type
      when MDNS::Type::A, MDNS::Type::AAAA
        str << answer.address
      when MDNS::Type::PTR
        str << address.address
        str << " (PTR)"
      else
        str << answer.type.to_s
      end
    end
  }.join("\n")
  puts "\n\n\n"
end

```
