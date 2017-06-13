use collections = "collections"

class Parser

    var _offset: USize = 0
    let data: Array[U8 val] box

    new create(data': Array[U8 val] box) =>
        data = data'

    fun ref shift(): U8 val ? =>
        data(_offset = _offset + 1)
    
    fun ref shiftN(length: USize): Array[U8 val] val ? =>
        if ((_offset + length) > data.size()) then
            error
        end

        let start = _offset
        let finish = _offset + length
        
        recover
            let result = Array[U8 val]()
            while _offset < finish do
                result.push(shift())
            end
            result
         end

    fun ref apply(): Frame val ? =>
        parseFrame()

    fun ref parseFrame(): Frame val ? =>
        let version: U8 val = shift() and 0b0111
        let flags: U8 val = shift()
        let stream: U16 val = parseShort()

        let opcode = shift()
        let length: I32 val = parseInt()

        let body: (Request | Response) = match opcode
        | 0x00 => parseErrorResponse()
        | 0x01 => parseStartupRequest()
        | 0x02 => parseReadyResponse()
        | 0x03 => parseAuthenticateResponse()
        | 0x05 => parseOptionsRequest()
        | 0x06 => parseSupportedResponse()
        | 0x07 => parseQueryRequest()
        // | 0x08 => parseResultResponse()
        // | 0x09 => parsePrepareRequest()
        // | 0x0A => parseExecuteRequest()
        // | 0x0B => parseRegisterRequest()
        // | 0x0C => parseEventResponse()
        // | 0x0D => parseBatchRequest()
        // | 0x0E => parseAuthChallengeResponse()
        | 0x0F => parseAuthResponseRequest()
        // | 0x10 => parseAuthSuccessResponse()
        else error
        end

        Frame(version, flags, stream, body)

    fun ref parseErrorResponse(): ErrorResponse val ? =>
        ErrorResponse(parseInt(), parseString())

    fun ref parseStartupRequest(): StartupRequest val ? =>
        let map = parseStringMap()

        if map.contains("COMPRESSION") then
            StartupRequest(map("CQL_VERSION"), map("COMPRESSION"))
        else
            StartupRequest(map("CQL_VERSION"))
        end

    fun ref parseAuthResponseRequest(): AuthResponseRequest val ? =>
        let token = parseBytes()
        AuthResponseRequest(token)
    
    fun ref parseOptionsRequest(): OptionsRequest val =>
        OptionsRequest()
    
    fun ref parseReadyResponse(): ReadyResponse val =>
        ReadyResponse()

    fun ref parseAuthenticateResponse(): AuthenticateResponse val ? =>
        let authenticator_name: String = parseString()
        AuthenticateResponse(authenticator_name)

    fun ref parseSupportedResponse(): SupportedResponse val ? =>
        let map = parseStringMultiMap()

        let compression: Array[String val] val = if map.contains("COMPRESSION") then
            map("COMPRESSION")
        else
             recover Array[String val] end
        end

        let cql_version: Array[String val] val = if map.contains("CQL_VERSION") then
            map("CQL_VERSION")
        else
             recover Array[String val] end
        end

        SupportedResponse(cql_version, compression)


    fun ref parseQueryRequest(): QueryRequest val ? =>
        let query_string: String val = parseLongString()
        let consistency: Consistency val = parseConsistency()

        let flag = shift()
        let flags: QueryFlags ref = QueryFlags


        if (flag and Values.value()) == Values.value() then
            flags.set(Values)
        end

        if (flag and SkipMetadata.value()) == SkipMetadata.value() then
            flags.set(SkipMetadata)
        end

        if (flag and PageSize.value()) == PageSize.value() then
            flags.set(PageSize)
        end

        if (flag and WithPagingState.value()) == WithPagingState.value() then
            flags.set(WithPagingState)
        end

        if (flag and WithSerialConsistency.value()) == WithSerialConsistency.value() then
            flags.set(WithSerialConsistency)
        end

        if (flag and WithDefaultTimestamp.value()) == WithDefaultTimestamp.value() then 
            flags.set(WithDefaultTimestamp)
        end

        if (flag and WithNamesForValues.value()) == WithNamesForValues.value() then
            flags.set(WithNamesForValues)
        end

        let binding: (Array[QueryParameter val] val | None val) = if flags(Values) then
            recover
                let n: U16 val = parseShort()
                var i: U16 val = 0
                let result: Array[QueryParameter val] ref = Array[QueryParameter val]
                while i < n do
                    let value_size = parseInt()
                    result.push(if value_size < 0 then
                        None
                    else
                        shiftN(value_size.usize())
                    end)
                    i = i + 1
                end
                result
            end
        else
            None
        end

        let page_size: (None val | I32 val) = if flags(PageSize) then
            parseInt()
        else
            None
        end

        let paging_state: (None val | Array[U8 val] val) = if flags(WithPagingState) then
            parseBytes()
        else
            None
        end

        let serial_consistency: (None val | Serial val | LocalSerial val) = if flags(WithSerialConsistency) then
            parseConsistency() as (Serial val | LocalSerial val)
        else
            None
        end

        let timestamp: (None val | I64 val) = if flags(WithDefaultTimestamp) then
            parseLong()
        else
            None
        end

        // let query_parameters: Array[QueryParameter val] val
        QueryRequest(query_string, binding, consistency, not flags(SkipMetadata), page_size, paging_state, serial_consistency, timestamp)

    fun ref parseAuthSuccessResponse(): AuthSuccessResponse val ? =>
        let token = parseBytes()
        AuthSuccessResponse(token)

    fun ref parseString(): String val ? =>
        let length = parseShort().usize()
        String.from_array(shiftN(length))


    fun ref parseLongString(): String val ? =>
        let length = parseInt().usize()
        String.from_array(shiftN(length))


    fun ref parseStringList(): Array[String val] val ? =>
        recover
            let result = Array[String val]()
            let n: U16 val = parseShort()
            var i: U16 = 0
            while i < n do
                result.push(parseString())
                i = i + 1
            end
            result
        end

    fun ref parseShort(): U16 val ? =>
        let a = shift().u16()
        let b = shift().u16()
        ((a << 8) or b)

    fun ref parseInt(): I32 val ? =>
        let a = shift().i32()
        let b = shift().i32()
        let c = shift().i32()
        let d = shift().i32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun ref parseLong(): I64 val ? =>
        let a = shift().i64()
        let b = shift().i64()
        let c = shift().i64()
        let d = shift().i64()
        let e = shift().i64()
        let f = shift().i64()
        let g = shift().i64()
        let h = shift().i64()
        (a << 56) or (b << 48) or (c << 40) or (d << 32) or (e << 24) or (f << 16) or (g << 8) or h
        
    fun ref parseConsistency(): Consistency val ? =>
        match parseShort()
        | 0x0000 => AnyConsistency
        | 0x0001 => One
        | 0x0002 => Two
        | 0x0003 => Three
        | 0x0004 => Quorum
        | 0x0005 => All
        | 0x0006 => LocalQuorum
        | 0x0007 => EachQuorum
        | 0x0008 => Serial
        | 0x0009 => LocalSerial
        | 0x000A => LocalOne
        else AnyConsistency
        end

    fun ref parseStringMap(): collections.Map[String val, String val] val ? =>
        recover
            let pairs = parseShort()
            let result = collections.Map[String val, String val](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                let key = parseString()
                let value = parseString()
                result.insert(key, value)
                i = i + 1
            end
            result
        end

    fun ref parseStringMultiMap(): collections.Map[String val, Array[String val] val] ? =>
        recover
            let pairs = parseShort()
            let result = collections.Map[String val, Array[String val] val](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                let key = parseString()
                let value = parseStringList()
                result.insert(key, value)
                i = i + 1
            end
            result
        end


    fun ref parseBytes(): (Array[U8 val] val | None) ? =>
        let length = parseInt()
        if (length < 0) then
            None
        else
            shiftN(length.usize())
        end
