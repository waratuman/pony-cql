use collection = "collections"

primitive Visitor
    
    fun apply(frame: Frame val): Array[U8 val] val =>
        recover visitFrame(frame) end
    
    fun visitFrame(frame: Frame val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        let version: U8 = match frame.body
        | let b: Request => 0x7F and frame.version
        else frame.version
        end
        c.push(version)

        c.push(frame.flags)

        visitShort(frame.stream, c)

        let opcode: U8 = match frame.body
        | let b: StartupRequest => 0x01
        | let b: ReadyResponse => 0x02
        | let b: OptionsRequest => 0x05
        | let b: QueryRequest => 0x07
        | let b: AuthResponseRequest => 0x0F
        else 0
        end
    
        c.push(opcode)

        let body = Array[U8 val]()
        visitBody(frame.body, body)
        
        visitInt(body.size().i32(), c)

        c.append(body)
        
        c

    fun visitBody(body: Message val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        match consume body
        | let r: StartupRequest val => visitStartupRequest(r, c)
        | let r: ReadyResponse val => visitReadyResponse(r, c)
        | let r: AuthResponseRequest val => visitAuthResponseRequest(r, c)
        else c
        end

    fun visitStartupRequest(request: StartupRequest val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        let compression = request.compression
        let cqlVersion = request.cqlVersion
    
        let pairs: U16 = if compression is None then 1 else 2 end

        visitShort(pairs, c)

        match compression
        | let compression': String => 
            visitString("COMPRESSION", c)
            visitString(compression', c)
        end

        visitString("CQL_VERSION", c)
        visitString(cqlVersion, c)

        c

    fun visitOptionsRequest(request: OptionsRequest, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitAuthResponseRequest(request: AuthResponseRequest val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitBytes(request.token, c)
        c

    // fun visitQueryRequest(request: QueryRequest iso): Array[U8 val] val =>

    fun visitErrorResponse(response: ErrorResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitInt(response.code, c)
        visitString(response.message, c)
        c

    fun visitReadyResponse(response: ReadyResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitAuthenticateResponse(response: AuthenticateResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitString(response.authenticator_name, c)
        c

    fun visitAuthSuccessResponse(response: AuthSuccessResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitBytes(response.token, c)
        c

    fun visitNone(data: None val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitInt(value: I32 val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c.push((value >> 24).u8())
        c.push((value >> 16).u8())
        c.push((value >> 8).u8())
        c.push(value.u8())
        c

    fun visitShort(value: U16 val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c.push((value >> 8).u8())
        c.push(value.u8())
        c

    fun visitBytes(data: (None | Array[U8 val] val), c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        match data
        | None => visitInt(-1, c)
        | let d: Array[U8 val] val =>
            visitInt(d.size().i32(), c)
            for byte in d.values() do
                c.push(byte)
            end
        end
        c

    fun visitString(data: String val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitShort(data.size().u16(), c)
        for byte in data.array().values() do
            c.push(byte)
        end
        c

    fun visitStringMap(data: collection.Map[String val, String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitShort(data.size().u16(), c)
        for pairs in data.pairs() do
            visitString(pairs._1, c)
            visitString(pairs._2, c)
        end
        c

    // fun visitLongString(collector: Array[U8 val] ref, data: String iso): Array[U8 val] ref =>

