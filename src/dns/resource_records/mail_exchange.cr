module MDNS::RR
  # MX record
  class MailExchange < BinData
    endian big

    uint16 :preference
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
