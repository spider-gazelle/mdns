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

  IPv4 = Socket::IPAddress.new("224.0.0.251", 5353)
  IPv6 = Socket::IPAddress.new("FF02::FB", 5353)
end

require "./message"
