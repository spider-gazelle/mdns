module MDNS::RR
  class HardwareInfo < BinData
    endian big

    field cpu : String
    field os : String
  end
end
