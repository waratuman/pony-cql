primitive Parser

    fun apply(data: Array[U8 val] val): Message val ? =>
        parseMessage(data)

    fun parseMessage(data: Array[U8 val] val): Message val ? =>
        let version: U8 val = data(0) and 0b0111
        let flags: U8 val = data(1)
        let stream: U16 val = parseShort(recover data.slice(2,4) end) // Bytes.u16(recover data.slice(2,4) end)

        let opcode = data(4)
        let length: I32 val = parseInt(recover data.slice(5,9) end)
        let body' = recover data.slice(9, 9 + length.usize()) end
    
        let body: (Request | Response) = match opcode
        // | 0x00 =>
        //     body = ErrorRequest.decode(consume body')
        | 0x01 => parseStartupRequest(consume body')
        | 0x02 => parseReadyResponse(consume body')
        | 0x05 => parseOptionsRequest(consume body')
        | 0x0F => parseAuthResponseRequest(consume body')
        else error
        end

        Message(version, flags, stream, body)

    fun parseStartupRequest(data: Array[U8 val] val): StartupRequest val ? =>
        let pairs: U16 = parseShort(recover data.slice(0, 2) end)

        var cqlVersion: String = ""
        var compression: (String | None) = None
        var dataIndex: U16 = 2
        var processedPairs: U16 = 0
        while processedPairs < pairs do
            let keyLength = parseShort(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let key: String = String.from_array(recover data.slice((dataIndex = dataIndex + keyLength).usize(), dataIndex.usize()) end)
            let valueLength = parseShort(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let value: String = String.from_array(recover data.slice((dataIndex = dataIndex + valueLength).usize(), dataIndex.usize()) end)

            if key == "CQL_VERSION" then
                cqlVersion = value
            elseif key == "COMPRESSION" then
                compression = value
            end
            
            processedPairs = processedPairs + 1
        end

        StartupRequest(cqlVersion, compression)

    fun parseAuthResponseRequest(data: Array[U8 val] val): AuthResponseRequest val ? =>
        let length: I32 = parseInt(recover data.slice(0, 4) end)

        let token: (None | Array[U8 val] val) = if (length < 0) then
            None
        else
            recover data.slice(4, 4 + length.usize()) end
        end

        AuthResponseRequest(token)
    
    fun parseOptionsRequest(data: Array[U8 val] val): OptionsRequest val =>
        OptionsRequest()
    
    fun parseReadyResponse(data: Array[U8 val] val): ReadyResponse val =>
        ReadyResponse()

    fun parseShort(data: Array[U8 val] val): U16 val ? =>
        let a = data(0).u16()
        let b = data(1).u16()
        ((a << 8) or b)

    fun parseInt(data: Array[U8 val] val): I32 val ? =>
        let a = data(0).i32()
        let b = data(1).i32()
        let c = data(2).i32()
        let d = data(3).i32()
        (a << 24) or (b << 16) or (c << 8) or d
