use collection = "collections"

primitive Visitor
    
    fun apply(message: Message val): Array[U8 val] val =>
        recover visitMessage(message) end
    
    fun visitMessage(message: Message val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        let version: U8 = match message.body
        | let b: Request => 0x7F and message.version
        // | Response => 0xFF or message.version
        else message.version
        end
        c.push(version)

        c.push(message.flags)

        visitShort(message.stream, c)

        let opcode: U8 = match message.body
        | let b: StartupRequest => 0x01
        | let b: ReadyResponse => 0x02
        | let b: OptionsRequest => 0x05
        | let b: QueryRequest => 0x07
        | let b: AuthResponseRequest => 0x0F
        else 0
        end
    
        c.push(opcode)

        let body = Array[U8 val]()
        visitBody(message.body, body)
        
        visitInt(body.size().i32(), c)

        c.append(body)
        
        c

    fun visitBody(body: (Request val | Response val), c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
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
        let token = request.token

        match token
        | None => visitInt(-1, c)
        | let t: Array[U8 val] val => visitBytes(t, c)
        end
        
        c

    // fun visitQueryRequest(request: QueryRequest iso): Array[U8 val] val =>

    fun visitReadyResponse(response: ReadyResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitAuthenticateResponse(response: AuthenticateResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitString(response.authenticator, c)
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

    fun visitBytes(data: Array[U8 val] val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitInt(data.size().i32(), c)
        for byte in data.values() do
            c.push(byte)
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

