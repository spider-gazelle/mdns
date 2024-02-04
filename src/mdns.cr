require "bindata"

module MDNS
  # RFC 1035
  enum OperationCode
    Query  = 0
    IQuery = 1
    Status = 2
    Notify = 4
    Update = 5
  end

  enum ResponseCode
    # RFC 1035
    NoError        = 0
    FormatError    = 1
    ServerFailure  = 2
    NameError      = 3
    NotImplemented = 4
    Refused        = 5

    # RFC 2136
    YXDomain =  6
    YXRRSet  =  7
    NXRRSet  =  8
    NotAuth  =  9
    NotZone  = 10
  end

  PORT = 5353
  IPv4 = Socket::IPAddress.new("224.0.0.251", PORT)
  IPv6 = Socket::IPAddress.new("FF02::FB", PORT)

  enum RecordClass
    Internet =   1
    CS_NET   =   2
    CHAOS    =   3
    Hesiod   =   4
    None     = 254
    AnyKlass = 255
  end

  # https://tools.ietf.org/html/rfc1035#section-3.2.2
  # https://en.wikipedia.org/wiki/List_of_DNS_record_types
  enum Type : UInt16
    MDNS       =  0
    A          =  1 # RFC 1035, Section 3.4.1
    NS         =  2 # RFC 1035, Section 3.3.11
    MD         =  3 # RFC 1035, Section 3.3.4 (obsolete)
    MF         =  4 # RFC 1035, Section 3.3.5 (obsolete)
    CNAME      =  5 # RFC 1035, Section 3.3.1
    SOA        =  6 # RFC 1035, Section 3.3.13
    MB         =  7 # RFC 1035, Section 3.3.3
    MG         =  8 # RFC 1035, Section 3.3.6
    MR         =  9 # RFC 1035, Section 3.3.8
    NULL       = 10 # RFC 1035, Section 3.3.10
    WKS        = 11 # RFC 1035, Section 3.4.2 (deprecated)
    PTR        = 12 # RFC 1035, Section 3.3.12
    HINFO      = 13 # RFC 1035, Section 3.3.2
    MINFO      = 14 # RFC 1035, Section 3.3.7
    MX         = 15 # RFC 1035, Section 3.3.9
    TXT        = 16 # RFC 1035, Section 3.3.14
    RP         = 17 # RFC 1183, Section 2.2
    AFSDB      = 18 # RFC 1183, Section 1
    X25        = 19 # RFC 1183, Section 3.1
    ISDN       = 20 # RFC 1183, Section 3.2
    RT         = 21 # RFC 1183, Section 3.3
    NSAP       = 22 # RFC 1706, Section 5
    NSAP_PTR   = 23 # RFC 1348 (obsolete)
    SIG        = 24 # RFC 2535, Section 4.1
    KEY        = 25 # RFC 2535, Section 3.1
    PX         = 26 # RFC 2163,
    GPOS       = 27 # RFC 1712 (obsolete)
    AAAA       = 28 # RFC 1886, Section 2.1
    LOC        = 29 # RFC 1876
    NXT        = 30 # RFC 2535, Section 5.2 obsoleted by RFC3755
    EID        = 31 # draft-ietf-nimrod-dns-xx.txt
    NIMLOC     = 32 # draft-ietf-nimrod-dns-xx.txt
    SRV        = 33 # RFC 2052
    ATMA       = 34 # ???
    NAPTR      = 35 # RFC 2168
    KX         = 36 # RFC 2230
    CERT       = 37 # RFC 2538
    DNAME      = 39 # RFC 2672
    OPT        = 41 # RFC 2671
    APL        = 42 # RFC 3123
    DS         = 43 # RFC 4034
    SSHFP      = 44 # RFC 4255
    IPSECKEY   = 45 # RFC 4025
    RRSIG      = 46 # RFC 4034
    NSEC       = 47 # RFC 4034
    DNSKEY     = 48 # RFC 4034
    DHCID      = 49 # RFC 4701
    NSEC3      = 50 # RFC 5155
    NSEC3PARAM = 51 # RFC 5155
    TLSA       = 52 # RFC 6698
    HIP        = 55 # RFC 5205
    CDS        = 59 # RFC 7344
    CDNSKEY    = 60 # RFC 7344
    SPF        = 99 # RFC 4408
    # UINFO      =   100 # non-standard
    # UID        =   101 # non-standard
    # GID        =   102 # non-standard
    # UNSPEC     =   103 # non-standard
    TKEY  =   249 # RFC 2930
    TSIG  =   250 # RFC 2931
    IXFR  =   251 # RFC 1995
    AXFR  =   252 # RFC 1035
    MAILB =   253 # RFC 1035 (MB, MG, MR)
    MAILA =   254 # RFC 1035 (obsolete - see MX)
    ANY   =   255 # RFC 1035
    URI   =   256 # RFC 7553
    CAA   =   257 # RFC 6844
    DLV   = 32769 # RFC 4431 (informational)
    WINS  = 65281 # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dnsp/39b03b89-2264-4063-8198-d62f62a6441a
    WINSR = 65282 # reverse WINS
    ANAME = 65305 # draft-ietf-dnsop-aname-01
  end
end

require "./dns/message"
require "./comms/client"
require "./comms/server"
