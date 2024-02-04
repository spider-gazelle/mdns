module MDNS::RR
  # described by https://tools.ietf.org/html/rfc2671
  class Option < BinData
    endian big

    field code : UInt16
    field data_size : UInt16, value: ->{ data.size.to_u8 }
    field data : Bytes, length: ->{ data_size }

    property max_udp_payload : Int32 = 0
  end
end
