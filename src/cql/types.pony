use collection = "collections" 

// // type FlagSeq is Array[Flag]

// primitive Error is collection.Flag[U8]
//     fun value(): U8 => 0x00
//     fun string(): String => "Error"
// primitive Startup is collection.Flag[U8]
//     fun value(): U8 => 0x01
//     fun string(): String => "Startup"
// primitive Ready is collection.Flag[U8]
//     fun value(): U8 => 0x02
//     fun string(): String => "Ready"
// primitive Authenticate is collection.Flag[U8]
//     fun value(): U8 => 0x03
//     fun string(): String => "Authenticate"
// primitive Options is collection.Flag[U8]
//     fun value(): U8 => 0x05
//     fun string(): String => "Options"
// primitive Supported is collection.Flag[U8]
//     fun value(): U8 => 0x06
//     fun string(): String => "Supported"
// primitive Query is collection.Flag[U8]
//     fun value(): U8 => 0x07
//     fun string(): String => "Query"
// primitive Result is collection.Flag[U8]
//     fun value(): U8 => 0x08
//     fun string(): String => "Result"
// primitive Prepare is collection.Flag[U8]
//     fun value(): U8 => 0x09
//     fun string(): String => "Prepare"
// primitive Execute is collection.Flag[U8]
//     fun value(): U8 => 0x0A
//     fun string(): String => "Execute"
// primitive Register is collection.Flag[U8]
//     fun value(): U8 => 0x0B
//     fun string(): String => "Register"
// primitive Event is collection.Flag[U8]
//     fun value(): U8 => 0x0C
//     fun string(): String => "Event"
// primitive Batch is collection.Flag[U8]
//     fun value(): U8 => 0x0D
//     fun string(): String => "Batch"
// primitive AuthChallenge is collection.Flag[U8]
//     fun value(): U8 => 0x0E
//     fun string(): String => "AuthChallenge"
// primitive AuthResponse is collection.Flag[U8]
//     fun value(): U8 => 0x0F
//     fun string(): String => "AuthResponse"
// primitive AuthSuccess is collection.Flag[U8]
//     fun value(): U8 => 0x10
//     fun string(): String => "AuthSuccess"

// type OpCode is (
//     Error | Startup | Ready | Authenticate | Options | Supported | Query |
//     Result | Prepare | Execute | Register | Event | Batch | AuthChallenge |
//     AuthResponse | AuthSuccess
// )

type Body is ( Array[U8 val] val )

type EncodedBody is ( Array[U8 val] val | None val )

// Consistency 
// primitive CAny
//     fun value(): U8 => 0x0000
primitive One
    // fun value(): U8 => 0x0001
primitive Two
    // fun value(): U8 => 0x0002
primitive Three
    // fun value(): U8 => 0x0003
primitive Quorum
    // fun value(): U8 => 0x0004
primitive All
    // fun value(): U8 => 0x0005
primitive LocalQuorum
    // fun value(): U8 => 0x0006
primitive EachQuorum
    // fun value(): U8 => 0x0007
primitive Serial
    // fun value(): U8 => 0x0008
primitive LocalSerial
    // fun value(): U8 => 0x0009
primitive LocalOne
    // fun value(): U8 => 0x000A

type Consistency is (
    Any | One | Two | Three | Quorum | All | LocalQuorum | EachQuorum | Serial
    | LocalSerial | LocalOne
)

primitive Values is collection.Flag[U8]
    fun value(): U8 => 0x01
    fun string(): String => "Values"

primitive SkipMetadata is collection.Flag[U8]
    fun value(): U8 => 0x02
    fun string(): String => "SkipMetadata"

primitive PageSize is collection.Flag[U8]
    fun value(): U8 => 0x04
    fun string(): String => "PageSize"

primitive WithPagingState is collection.Flag[U8]
    fun value(): U8 => 0x08
    fun string(): String => "WithPagingState"

primitive WithSerialConsistency is collection.Flag[U8]
    fun value(): U8 => 0x10
    fun string(): String => "WithSerialConsistency"

primitive WithDefaultTimestamp is collection.Flag[U8]
    fun value(): U8 => 0x20
    fun string(): String => "WithDefaultTimestamp"

primitive WithNamesForValues is collection.Flag[U8]
    fun value(): U8 => 0x40
    fun string(): String => "WithNamesForValues"

type QueryFlags is (
    Values | SkipMetadata | PageSize | WithPagingState | WithSerialConsistency
    | WithDefaultTimestamp | WithNamesForValues
)
