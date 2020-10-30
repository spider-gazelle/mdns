module MDNS
  # described by https://tools.ietf.org/html/rfc2671
  class Option < BinData
    endian big

    uint16 :code
    uint16 :data_size, value: ->{ data.size.to_u8 }
    bytes :data, length: ->{ data_size }

    property max_udp_payload : Int32 = 0
  end
end
