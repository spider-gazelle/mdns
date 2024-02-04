module MDNS::RR
  # MX record
  class MailExchange < BinData
    endian big

    field preference : UInt16
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
