module MDNS::RR
  # SRV details
  class Service < BinData
    endian big

    uint16 :priority
    uint16 :weight
    uint16 :port

    variable_array raw_domain_name : DomainNameComponent, read_next: ->{
      if name = raw_domain_name[-1]?
        name.read_next?
      else
        true
      end
    }

    include DomainNameHelpers
  end
end
