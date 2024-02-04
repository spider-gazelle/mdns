require "../mdns"

module MDNS
  # A single component of the domain name.
  # i.e. `.com`
  class DomainNameComponent < BinData
    endian big

    enum Indicator
      String  = 0
      Pointer = 3
    end

    bit_field do
      bits 2, indicator : Indicator = Indicator::String
      bits 6, :size, value: ->{ compressed? ? size : name.bytesize.to_u8 }
    end

    field pointer_low : UInt8, onlyif: ->{ compressed? }
    field name : String, length: ->{ compressed? ? 0 : size }

    def read_next?
      size > 0_u8 && !compressed?
    end

    def compressed?
      indicator.pointer?
    end

    def get_name(io : IO::Memory) : String
      if compressed?
        pointer = (size.to_i32 << 8) | pointer_low.to_i32
        io.pos = pointer
        components = io.read_bytes(DomainNamePointer)
        components.original_io = io
        components.domain_name
      else
        name
      end
    end
  end

  module DomainNameHelpers
    property original_io : IO::Memory? = nil

    def set_io(io : IO::Memory?)
      @original_io = io
      self
    end

    # will work with compressed versions
    def domain_name
      if io = original_io
        raw_domain_name.map(&.get_name(io)).reject(&.empty?).join('.')
      else
        raw_domain_name.map(&.name).reject(&.empty?).join('.')
      end
    end

    def domain_name=(name)
      self.raw_domain_name = name.split('.').reject(&.empty?).map do |part|
        component = DomainNameComponent.new
        component.name = part
        component
      end
      # ends with a blank component
      self.raw_domain_name << DomainNameComponent.new
      name
    end
  end

  # The list of components that make up a domain name
  class DomainNamePointer < BinData
    endian big

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
