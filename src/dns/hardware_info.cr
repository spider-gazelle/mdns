module MDNS
  class HardwareInfo < BinData
    endian big

    string :cpu
    string :os
  end
end
