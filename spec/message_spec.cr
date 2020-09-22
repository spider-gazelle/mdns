require "./spec_helper"

module MDNS
  describe MDNS do
    it "should parse a DNS query" do
      io = IO::Memory.new(Bytes[
        # header
        0xAA, 0xAA, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,
        # query
        7, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 3, 0x63, 0x6F, 0x6D,
        0, 0, 1, 0, 1,
      ])

      msg = io.read_bytes(Message)
      msg.message_id.should eq(0xAAAA)
      msg.is_response.should eq(false)
      msg.operation_code.should eq(OperationCode::Query)
      msg.authoritative_answer.should eq(false)
      msg.truncation.should eq(false)
      msg.recursion_desired.should eq(true)
      msg.recursion_available.should eq(false)
      msg.response_code.should eq(ResponseCode::NoError)

      msg.query_count.should eq(1)
      msg.answer_count.should eq(0)

      msg.queries[0].domain_name.should eq("example.com")
      msg.answers.empty?.should eq(true)
    end

    it "should parse a DNS response" do
      io = IO::Memory.new(Bytes[
        # header
        0xAA, 0xAA, 0x81, 0x80, 0, 1, 0, 1, 0, 0, 0, 0,
        # query
        7, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 3, 0x63, 0x6F, 0x6D,
        0, 0, 1, 0, 1,
        # response
        0xC0, 0x0C, 0, 1, 0, 1, 0, 0, 0x18, 0x4C, 0, 4, 0x5D, 0xB8, 0xD8, 0x22,
      ])

      msg = io.read_bytes(Message)
      msg.message_id.should eq(0xAAAA)
      msg.is_response.should eq(true)
      msg.operation_code.should eq(OperationCode::Query)
      msg.authoritative_answer.should eq(false)
      msg.truncation.should eq(false)
      msg.recursion_desired.should eq(true)
      msg.recursion_available.should eq(true)
      msg.response_code.should eq(ResponseCode::NoError)

      msg.query_count.should eq(1)
      msg.answer_count.should eq(1)

      msg.queries[0].domain_name.should eq("example.com")

      ans = msg.answers[0]
      ans.type.a?.should eq(true)
      ans.klass.internet?.should eq(true)
      ans.domain_name(io).should eq("example.com")
      ans.address.should eq("93.184.216.34")
    end

    it "should make and parse a DNS request" do
      msg = Message.new
      msg.message_id = 12_u16
      msg.query("example.com")

      dns_server = Socket::IPAddress.new("8.8.8.8", 53)
      sock = Socket.udp(Socket::Family::INET)
      sock.send(msg, to: dns_server)
      # 512 is the max size of a UDP message
      response_data, client_addr = sock.receive(512)
      sock.close

      io = IO::Memory.new(response_data)
      response = io.read_bytes(Message)

      # Parse response
      msg.message_id.should eq(response.message_id)
      response.is_response.should eq(true)
      response.answer_count.should eq(1)

      ans = response.answers[0]
      ans.type.a?.should eq(true)
      ans.klass.internet?.should eq(true)
      ans.domain_name(io).should eq("example.com")
      ans.address.should eq("93.184.216.34")
    end

    it "should parse a mDNS response" do
      data = "0000840000000008000000052437443339373233312d313843342d354136432d413432362d363945394133333643314331085f686f6d656b6974045f746370056c6f63616c00001080010000119400282773693d36344145323939312d364646382d344239392d383434352d434144343433353146353043095f7365727669636573075f646e732d7364045f756470c03f000c0001000011940002c031c031000c0001000011940002c00cc00c0021800100000078001500000000c0000c416e67656c61732d69506164c03f0134014301380131013001430142013701450134014201370145013801430131013001300130013001300130013001300130013001300130013001380145014603697036046172706100000c8001000000780002c0bd023236023836033136380331393207696e2d61646472c110000c8001000000780002c0bdc0bd001c8001000000780010fe800000000000001c8e7b4e7bc018c4c0bd00018001000000780004c0a8561ac00c002f8001000011940009c00c00050000800040c0cc002f8001000000780006c0cc00020008c122002f8001000000780006c12200020008c0bd002f8001000000780008c0bd00044000000800002905a00000119400120004000e00eeeed281c05aaeccd281c05aae".hexbytes
      io = IO::Memory.new(data)
      response = io.read_bytes(Message)
    end

    it "should make and parse a mDNS request" do
      msg = Message.new
      msg.message_id = 12_u16
      msg.query("_homekit._tcp.local")

      dns_server = MDNS::IPv4
      sock = UDPSocket.new
      sock.join_group(dns_server)
      sock.multicast_loopback = false
      # sock.send(msg
    end
  end
end
