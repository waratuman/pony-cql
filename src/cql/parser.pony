primitive Parser

    fun apply(data: Array[U8 val] val): Message val ? =>
        parseMessage(data)

    fun parseMessage(data: Array[U8 val] val): Message val ? =>
        let version: U8 val = data(0) and 0b0111
        let flags: U8 val = data(1)
        let stream: U16 val = Bytes.u16(recover data.slice(2,4) end)

        let opcode = data(4)
        let length: U32 val = Bytes.u32(recover data.slice(5,9) end)
        let body' = recover data.slice(9, 9 + length.usize()) end
    
        let body: Request = match opcode
        // | 0x00 =>
        //     body = ErrorRequest.decode(consume body')
        | 0x01 => parseStartupRequest(consume body')
        | 0x05 => parseOptionsRequest(consume body')
        | 0x0F => parseAuthResponseRequest(consume body')
        else error
        end

        recover Message(version, flags, stream, body) end

    fun parseRequest(data: Array[U8 val] val): Request val ? =>
        parseStartupRequest(data)
    
    fun parseStartupRequest(data: Array[U8 val] val): StartupRequest val ? =>
        let pairs: U16 = Bytes.u16(recover data.slice(0, 2) end)

        var cqlVersion: String = ""
        var compression: (String | None) = None
        var dataIndex: U16 = 2
        var processedPairs: U16 = 0
        while processedPairs < pairs do
            let keyLength = Bytes.u16(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let key: String = String.from_array(recover data.slice((dataIndex = dataIndex + keyLength).usize(), dataIndex.usize()) end)
            let valueLength = Bytes.u16(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let value: String = String.from_array(recover data.slice((dataIndex = dataIndex + valueLength).usize(), dataIndex.usize()) end)

            if key == "CQL_VERSION" then
                cqlVersion = value
            elseif key == "COMPRESSION" then
                compression = value
            end
            
            processedPairs = processedPairs + 1
        end

        recover StartupRequest(cqlVersion, compression) end

    fun parseAuthResponseRequest(data: Array[U8 val] val): AuthResponseRequest val ? =>
        let length: I32 = Bytes.i32(recover data.slice(0, 4) end)

        let token: (None | Array[U8 val] val) = if (length < 0) then
            None
        else
            recover data.slice(4, 4 + length.usize()) end
        end

        recover AuthResponseRequest(token) end
    
    fun parseOptionsRequest(data: Array[U8 val] val): OptionsRequest val =>
        recover OptionsRequest() end
    