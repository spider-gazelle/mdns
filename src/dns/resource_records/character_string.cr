module MDNS::RR
  class CharacterString < BinData
    endian big

    uint8 :text_size, value: ->{ text.size.to_u8 }
    string :text, length: ->{ text_size }
  end
end
