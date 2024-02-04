module MDNS::RR
  # SRV details
  class Service < BinData
    endian big

    field priority : UInt16
    field weight : UInt16
    field port : UInt16

    field raw_domain_name : Array(DomainNameComponent), read_next: ->{
      if name = raw_domain_name[-1]?
        name.read_next?
      else
        true
      end
    }

    include DomainNameHelpers
  end
end
