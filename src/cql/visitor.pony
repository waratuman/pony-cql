primitive Visitor
    
    fun apply(message: Request val): Array[U8 val] val =>
        recover visitRequest(Array[U8 val](), message) end
    
    fun visit(collector: Array[U8 val] ref, message: Request val): Array[U8 val] ref => 
        visitRequest(collector, consume message)

    fun visitRequest(c: Array[U8 val] ref, request: Request val): Array[U8 val] ref =>
        match consume request
        | let r: StartupRequest val => visitStartupRequest(c, r)
        | let r: AuthResponseRequest val => visitAuthResponseRequest(c, r)
        else
            Array[U8 val]()
        end
        c

    fun visitStartupRequest(collector: Array[U8 val] ref, request: StartupRequest val): Array[U8 val] ref =>
        let compression = request.compression
        let cqlVersion = request.cqlVersion
    
        let c = Array[U8 val]()
        var pairs: U16 = 1

        match compression
        | let compression': String => 
            pairs = pairs + 1
            visitString(c, "COMPRESSION")
            visitString(c, compression')
        end

        visitString(c, "CQL_VERSION")
        visitString(c, cqlVersion)

        for byte in Bytes.of[U16](pairs).reverse().values() do
            c.unshift(byte)
        end

        collector.append(c)
        collector

    fun visitAuthResponseRequest(c: Array[U8 val] ref, request: AuthResponseRequest val): Array[U8 val] ref =>
        let token = request.token

        match token
        | None => visitInt(c, -1)
        | let t: Array[U8 val] val => visitBytes(c, t)
        end
        
        c

    // fun visitQueryRequest(request: QueryRequest iso): Array[U8 val] val =>

    fun visitNone(c: Array[U8 val] ref, data: None val): Array[U8 val] ref =>
        c

    fun visitInt(c: Array[U8 val] ref, value: I32 val): Array[U8 val] ref =>
        c.push((value >> 24).u8())
        c.push((value >> 16).u8())
        c.push((value >> 8).u8())
        c.push(value.u8())
        c

    fun visitShort(c: Array[U8 val] ref, value: U16 val): Array[U8 val] ref =>
        c.push((value >> 8).u8())
        c.push(value.u8())
        c

    fun visitBytes(c: Array[U8 val] ref, data: Array[U8 val] val): Array[U8 val] ref =>
        visitInt(c, data.size().i32())
        for byte in data.values() do
            c.push(byte)
        end
        c

    fun visitString(c: Array[U8 val] ref, data: String val): Array[U8 val] ref =>
        visitShort(c, data.size().u16())
        for byte in data.array().values() do
            c.push(byte)
        end
        c

    // fun visitStringMap(c: Array[U8 val] ref, data: collection.Map[String val, String val] iso): Array[U8 val] ref =>

    // fun visitLongString(collector: Array[U8 val] ref, data: String iso): Array[U8 val] ref =>

