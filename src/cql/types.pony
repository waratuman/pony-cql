use collection = "collections" 

primitive Compression   fun value(): U8 => 0x01
primitive Tracing       fun value(): U8 => 0x02
primitive CustomPayload fun value(): U8 => 0x04
primitive Warning       fun value(): U8 => 0x08
primitive Beta          fun value(): U8 => 0x10

type Flag is collection.Flags[(Compression | Tracing | CustomPayload | Warning | Beta), U8]

// type FlagSeq is Array[Flag]

primitive Error is collection.Flag[U8]
    fun value(): U8 => 0x00
    fun string(): String => "Error"
primitive Startup is collection.Flag[U8]
    fun value(): U8 => 0x01
    fun string(): String => "Startup"
primitive Ready is collection.Flag[U8]
    fun value(): U8 => 0x02
    fun string(): String => "Ready"
primitive Authenticate is collection.Flag[U8]
    fun value(): U8 => 0x03
    fun string(): String => "Authenticate"
primitive Options is collection.Flag[U8]
    fun value(): U8 => 0x05
    fun string(): String => "Options"
primitive Supported is collection.Flag[U8]
    fun value(): U8 => 0x06
    fun string(): String => "Supported"
primitive Query is collection.Flag[U8]
    fun value(): U8 => 0x07
    fun string(): String => "Query"
primitive Result is collection.Flag[U8]
    fun value(): U8 => 0x08
    fun string(): String => "Result"
primitive Prepare is collection.Flag[U8]
    fun value(): U8 => 0x09
    fun string(): String => "Prepare"
primitive Execute is collection.Flag[U8]
    fun value(): U8 => 0x0A
    fun string(): String => "Execute"
primitive Register is collection.Flag[U8]
    fun value(): U8 => 0x0B
    fun string(): String => "Register"
primitive Event is collection.Flag[U8]
    fun value(): U8 => 0x0C
    fun string(): String => "Event"
primitive Batch is collection.Flag[U8]
    fun value(): U8 => 0x0D
    fun string(): String => "Batch"
primitive AuthChallenge is collection.Flag[U8]
    fun value(): U8 => 0x0E
    fun string(): String => "AuthChallenge"
primitive AuthResponse is collection.Flag[U8]
    fun value(): U8 => 0x0F
    fun string(): String => "AuthResponse"
primitive AuthSuccess is collection.Flag[U8]
    fun value(): U8 => 0x10
    fun string(): String => "AuthSuccess"

type OpCode is (
    Error | Startup | Ready | Authenticate | Options | Supported | Query |
    Result | Prepare | Execute | Register | Event | Batch | AuthChallenge |
    AuthResponse | AuthSuccess
)

// type StartupBody is collection.Map[String val, String val] val
// // type AuthResponseBody is Array[U8 val] val
// // type OptionsBody is None
// // // type QueryBody is (String, )
// // type PrepareBody is String
// // type Execute
// // type AuthenticateBody is None
// type ErrorBody is (U32, String)


type Body is (
    String
    | Array[U8 val] val
    | collection.Map[String val, String val] val
    | None val
)


type EncodedBody is ( Array[U8 val] val | None val )

