use collection = "collections" 

primitive Compression   fun value(): U8 => 0x01
primitive Tracing       fun value(): U8 => 0x02
primitive CustomPayload fun value(): U8 => 0x04
primitive Warning       fun value(): U8 => 0x08
primitive Beta          fun value(): U8 => 0x10

type Flag is collection.Flags[(Compression | Tracing | CustomPayload | Warning | Beta), U8]

class Message

    let version: U8 val
    let flags: U8 val
    let stream: U16 val
    let body: (Request val | Response val)

    new val create(version': U8 val, flags': U8 val, stream': U16 val, body': (Request val | Response val)) =>
        version = version'
        flags = flags'
        stream = stream'
        body = body'

    fun string(): String val =>
        body.string()
