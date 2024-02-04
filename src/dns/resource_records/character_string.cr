module MDNS::RR
  class CharacterString < BinData
    endian big

    field text_size : UInt8, value: ->{ text.size.to_u8 }
    field text : String, length: ->{ text_size }
  end
end
