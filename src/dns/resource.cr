require "./domain_name"
require "./option"
require "./hardware_info"

module MDNS
  # Inheriting the domain name structure and extending it with resource info
  class Resource < DomainNamePointer
    endian big

    enum_field UInt16, type : Type = Type::A

    bit_field do
      bool :flush_cache, default: false
      bits 15, record_class_raw, default: RecordClass::Internet.to_u16
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

    def record_class
      RecordClass.from_value(record_class_raw)
    end

    def record_class=(klass : RecordClass)
      self.record_class_raw = klass.to_u16
    end

    def payload
      case type
      when Type::A
        Socket::IPAddress.new(data.map(&.to_s(10)).join("."), 0)
      when Type::AAAA
        Socket::IPAddress.new(data.hexstring.scan(/..../).map(&.to_a.first).join(":"), 0)
      when Type::OPT
        option
      when Type::HINFO
        IO::Memory.new(data).read_bytes(HardwareInfo)
      when Type::CNAME, Type::ANAME, Type::NS, Type::PTR
        # when Type::HINFO
        #  IO::Memory.new(data).read_bytes(HardwareInfo)
      else
        data
      end
    end

    # returns the sender's UDP payload size + option data
    protected def option
      opt = IO::Memory.new(data).read_bytes(Option)
      opt.max_udp_payload = record_class_raw.to_i
      opt
    end
  end
end
