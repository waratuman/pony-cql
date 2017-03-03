class Message

    let version: U8 val
    let opcode: OpCode val
    let flags: U8 val
    let stream: U16 val
    let length: U32 val
    let body: Request // (Request | Response)

    new create(version': U8 val, opcode': OpCode val, flags': U8 val, stream': U16 val, length': U32 val, body': Request) =>
        version = version'
        opcode = opcode'
        flags = flags'
        stream = stream'
        length = length'
        body = body'
