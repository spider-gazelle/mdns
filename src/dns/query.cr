require "./domain_name"

module MDNS
  # Inheriting the domain name structure and extending it with query params
  class Query < DomainNamePointer
    enum_field UInt16, type : Type = Type::A

    bit_field do
      bool :unicast_response, default: false
      enum_bits 15, record_class : RecordClass = RecordClass::Internet
    end
  end
end
