module MDNS::RR
  class HardwareInfo < BinData
    endian big

    string :cpu
    string :os
  end
end
