require "../mdns"
require "./query"
require "./resource"

module MDNS
  # https://tools.ietf.org/html/rfc1035#page-26
  class Message < BinData
    endian big

    field message_id : UInt16

    bit_field do
      bool :is_response, default: false

      bits 4, operation_code : OperationCode = OperationCode::Query
      bool :authoritative_answer, default: false
      bool :truncation, default: false
      bool :recursion_desired, default: true
      bool :recursion_available, default: false

      # Should always be 0
      bits 3, :reserved, value: ->{ 0_u8 }
      bits 4, response_code : ResponseCode = ResponseCode::NoError
    end

    field query_count : UInt16, value: ->{ queries.size }
    field answer_count : UInt16, value: ->{ answers.size }
    field name_server_count : UInt16, value: ->{ name_servers.size }
    field additional_record_count : UInt16, value: ->{ additional.size }

    field queries : Array(Query), length: ->{ query_count }
    field answers : Array(Resource), length: ->{ answer_count }
    field name_servers : Array(Resource), length: ->{ name_server_count }
    field additional : Array(Resource), length: ->{ additional_record_count }

    def query(domain : String, type : Type = Type::PTR, record_class : RecordClass = RecordClass::Internet, unicast_response : Bool = false)
      q = Query.new
      q.type = type
      q.record_class = record_class
      q.domain_name = domain
      q.unicast_response = unicast_response
      queries << q
    end

    def response?
      is_response
    end

    def query?
      !is_response
    end

    # This is used for lazily decompressing the domain strings
    def set_io(io : IO::Memory)
      queries.each(&.original_io = io)
      answers.each(&.original_io = io)
      name_servers.each(&.original_io = io)
      additional.each(&.original_io = io)
      self
    end
  end
end
