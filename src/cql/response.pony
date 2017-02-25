class Response

    let version: U8 val
    let opcode: OpCode val
    let flags: U8 val
    let stream: U16 val
    let body: Array[U8 val] val

    new create(version': U8 val, opcode': OpCode val, flags': U8 val, stream': U16 val, body': Array[U8 val] val) =>
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
        
        opcode = if opcode' == 0x01 then
            Startup
        elseif opcode' == 0x02 then
            Ready
        else
            Error
        end

        body = recover data.slice(6) end

    fun string(): String =>
        "[" + stream.string() + "] " + opcode.string().upper()