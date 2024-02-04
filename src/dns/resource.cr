require "./domain_name"
require "./resource_records/option"
require "./resource_records/service"
require "./resource_records/hardware_info"
require "./resource_records/mail_exchange"
require "./resource_records/character_string"

module MDNS
  # Inheriting the domain name structure and extending it with resource info
  class Resource < DomainNamePointer
    endian big

    field type : Type = Type::A

    bit_field do
      bool :flush_cache, default: false
      bits 15, record_class_raw, default: RecordClass::Internet.to_u16
    end

    field raw_ttl : UInt32
    field data_size : UInt16, value: ->{ data.size.to_u8 }
    field data : Bytes, length: ->{ data_size }

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
      when Type::MX
        IO::Memory.new(data).read_bytes(RR::MailExchange).set_io(original_io)
      when Type::HINFO
        IO::Memory.new(data).read_bytes(RR::HardwareInfo)
      when Type::CNAME, Type::ANAME, Type::NS, Type::PTR
        IO::Memory.new(data).read_bytes(DomainNamePointer).set_io(original_io).domain_name
      when Type::TXT
        extract_strings
      when Type::SRV
        IO::Memory.new(data).read_bytes(RR::Service)
      else
        data
      end
    end

    # returns the sender's UDP payload size + option data
    protected def option
      opt = IO::Memory.new(data).read_bytes(RR::Option)
      opt.max_udp_payload = record_class_raw.to_i
      opt
    end

    protected def extract_strings
      strings = [] of String
      io = IO::Memory.new(data)
      loop do
        break if io.pos == io.size
        text = io.read_bytes(RR::CharacterString)
        strings << text.text
      end
      strings
    end
  end
end
