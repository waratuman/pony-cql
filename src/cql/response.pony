class Response

    let version: U8 val
    let opcode: OpCode val
    let flags: U8 val
    let stream: U16 val
    let body: Body

    new create(version': U8 val, opcode': OpCode val, flags': U8 val, stream': U16 val, body': Body) =>
        version = version'
        opcode = opcode'
        flags = flags'
        stream = stream'
        body = body'

    new decode(data: Array[U8 val] val) ? =>
        version = data(0) and 0b0111
        flags = data(1)
        stream = Bytes.to_u16(recover data.slice(2,4) end)

        let opcode' = data(4)
        let length: USize = Bytes.to_u32(recover data.slice(5,9) end).usize()
        let body' = recover data.slice(9, 9 + length) end
        
        match opcode'
        // | 0x00 =>
        //     opcode = Error
        //     body = decodeErrorBody(consume body')
        | 0x02 =>
            opcode = Ready
            body = None
        | 0x03 =>
            opcode = Authenticate
            body = decodeAuthenticateBody(consume body')
        | 0x06 =>
            opcode = Supported
            body = None
        | 0x08 =>
            opcode = Result
            body = None
        | 0x0C =>
            opcode = Event
            body = None
        | 0x0E =>
            opcode = AuthChallenge
            body = None
        | 0x10 =>
            opcode = AuthSuccess
            body = None
        else
            opcode = Error
            body = None
        end

    // fun tag decodeErrorBody(data: Array[U8 val] val): 
    fun tag decodeAuthenticateBody(data: Array[U8 val] val): String val ? =>
        recover
            let length: U16 = Bytes.to_u16(recover data.slice(0,2) end)
            String.from_array(recover data.slice(2, (2 + length).usize()) end)
        end

    fun string(): String val =>
        let bodyString = match body
        | let b: String => " " + b
        else
            ""
        end

        "[" + stream.string() + "] " + opcode.string().upper() + bodyString
        
