require "./domain_name"

module MDNS
  # https://tools.ietf.org/html/rfc1035#section-3.2.2
  enum Type
    MDNS  = 0
    A     = 1
    NS
    MD
    MF
    CNAME
    SOA
    MB
    MG
    MR
    NULL
    WKS
    PTR
    HINFO
    MINFO
    MX
    TXT

    # https://tools.ietf.org/html/rfc3596 (ipv6)
    AAAA = 28

    # https://tools.ietf.org/html/rfc2782
    # Servce record _service._protocol.target
    # i.e. _foobar._tcp.example.com
    # or _foobar._tcp.local
    SRV = 33

    # Query types
    AXFR       = 252
    MAILB      = 253
    MAILA      = 254
    AllRecords = 255
  end

  enum Klass
    Internet = 1
    CS_NET
    CHAOS
    Hesiod
    AnyKlass = 255
  end

  class Query < DomainNamePointer
    enum_field UInt16, type : Type = Type::A

    bit_field do
      bool :unicast_response, default: false
      enum_bits 15, klass : Klass = Klass::Internet
    end
  end

  class Resource < DomainNamePointer
    endian big

    enum_field UInt16, type : Type = Type::A

    bit_field do
      bool :flush_cache, default: false
      enum_bits 15, klass : Klass = Klass::Internet
    end

    uint32 :raw_ttl
    uint16 :data_size, value: ->{ data.size.to_u8 }
    bytes :data, length: ->{ data_size }

    def ttl
      raw_ttl.seconds
    end

    def ttl=(period : Time::Span)
      self.raw_ttl = period.to_i.to_u32
    end

    def address : String
      case type
      when Type::A
        data.map(&.to_s(10)).join(".")
      else
        raise "unknown format for type: #{type}"
      end
    end
  end
end
