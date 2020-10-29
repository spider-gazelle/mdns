require "bindata"

module MDNS
  enum OperationCode
    Query  = 0
    IQuery
    Status
  end

  enum ResponseCode
    NoError        = 0
    FormatError
    ServerFailure
    NameError
    NotImplemented
    Refused
  end

  PORT = 5353
  IPv4 = Socket::IPAddress.new("224.0.0.251", PORT)
  IPv6 = Socket::IPAddress.new("FF02::FB", PORT)
end

require "./dns/message"
require "./comms/client"
require "./comms/server"
