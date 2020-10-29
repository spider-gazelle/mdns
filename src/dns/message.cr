require "../mdns"
require "./query_resource"

module MDNS
  # https://tools.ietf.org/html/rfc1035#page-26
  class Message < BinData
    endian big

    uint16 :message_id

    bit_field do
      bool :is_response, default: false

      enum_bits 4, operation_code : OperationCode = OperationCode::Query
      bool :authoritative_answer, default: false
      bool :truncation, default: false
      bool :recursion_desired, default: true
      bool :recursion_available, default: false

      # Should always be 0
      bits 3, :reserved, value: ->{ 0_u8 }
      enum_bits 4, response_code : ResponseCode = ResponseCode::NoError
    end

    uint16 :query_count, value: ->{ queries.size }
    uint16 :answer_count, value: ->{ answers.size }
    uint16 :authority_record_count
    uint16 :additional_record_count

    array queries : Query, length: ->{ query_count }
    array answers : Resource, length: ->{ answer_count }

    def query(domain : String, type : Type = Type::PTR, klass : Klass = Klass::Internet, unicast_response : Bool = false)
      q = Query.new
      q.type = type
      q.klass = klass
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
  end
end
