use "net"
use "chrono"
use cql = "../cql"
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
        | let b: AuthenticateResponse => 0x03
        | let b: OptionsRequest => 0x05
        | let b: SupportedResponse => 0x06
        | let b: QueryRequest => 0x07
        // | let b:  => 0x08
        // | let b:  => 0x09
        // | let b:  => 0x0A
        // | let b:  => 0x0B
        // | let b:  => 0x0C
        // | let b:  => 0x0D
        // | let b:  => 0x0E
        | let b: AuthResponseRequest => 0x0F
        | let b: AuthSuccessResponse => 0x10
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
        | let r: ErrorResponse val => visitErrorResponse(r, c)      
        | let r: StartupRequest val => visitStartupRequest(r, c)
        | let r: ReadyResponse val => visitReadyResponse(r, c)
        | let r: AuthenticateResponse val => visitAuthenticateResponse(r, c)
        | let r: OptionsRequest val => visitOptionsRequest(r, c)
        | let r: SupportedResponse val => visitSupportedResponse(r, c)
        | let r: QueryRequest val => visitQueryRequest(r, c)
        // | let r: ResultResponse val => visitResultResponse(r, c)
        // | let r: PrepareRequest val => visitPrepareRequest(r, c)
        // | let r: ExecuteRequest val => visitExecuteRequest(r, c)
        // | let r: RegisterRequest val => visitRegisterRequest(r, c)
        // | let r: EventResponse val => visitEventResponse(r, c)
        // | let r: BatchRequest val => visitBatchRequest(r, c)
        // | let r: AuthChallengeResponse val => visitAuthChallengeResponse(r, c)
        | let r: AuthResponseRequest val => visitAuthResponseRequest(r, c)
        | let r: AuthSuccessResponse val => visitAuthSuccessResponse(r, c)
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

    fun visitQueryRequest(request: QueryRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        visitLongString(request.query, c)
        visitConsistency(request.consistency, c)

        var flag: QueryFlags ref = QueryFlags

        match request.queryParameters
        | let p: Array[QueryParameter val] val => flag.apply(Values)
        end
        
        if (not request.metadata) then
            flag.apply(SkipMetadata)
        end

        match request.pageSize
        | U32 => flag.apply(PageSize)
        end

        match request.pagingState
        | let _: Array[U8 val] val => flag.apply(WithPagingState)
        end

        match request.serialConsistency
        | let _: Serial val => flag.apply(WithSerialConsistency)
        | let _: LocalSerial val => flag.apply(WithSerialConsistency)
        end
    
        match request.timestamp
        | let _: U64 val => flag.apply(WithDefaultTimestamp)
        end

        c.push(flag.value())

        match request.queryParameters
        | let p: Array[QueryParameter val] val =>
            for value in p.values() do
                visitQueryParameter(value, c)
            end
        end

        c

    fun visitErrorResponse(response: ErrorResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitInt(response.code, c)
        visitString(response.message, c)
        c

    fun visitReadyResponse(response: ReadyResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitAuthenticateResponse(response: AuthenticateResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitString(response.authenticator_name, c)
        c

    fun visitSupportedResponse(response: SupportedResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitShort(2, c)
        visitString("COMPRESSION", c)
        visitStringList(response.compression, c)
        visitString("CQL_VERSION", c)
        visitStringList(response.cql_version, c)
        c       

    fun visitAuthSuccessResponse(response: AuthSuccessResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitBytes(response.token, c)
        c


    fun visitConsistency(consistency: Consistency val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match consistency
        | AnyConsistency => visitShort(0x0000, c)
        | One => visitShort(0x0001, c)
        | Two => visitShort(0x0002, c)
        | Three => visitShort(0x0003, c)
        | Quorum => visitShort(0x0004, c)
        | All => visitShort(0x0005, c)
        | LocalQuorum => visitShort(0x0006, c)
        | EachQuorum => visitShort(0x0007, c)
        | Serial => visitShort(0x0008, c)
        | LocalSerial => visitShort(0x0009, c)
        | LocalOne => visitShort(0x000A, c)
        end
        c
    
    fun visitNone(data: None val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitQueryParameter(parameter: QueryParameter val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let value_collector: Array[U8 val] ref = Array[U8 val]
        _visitQueryParameter(parameter, value_collector)
        visitInt(value_collector.size().i32(), c)
        c.append(value_collector)
        c
    fun _visitQueryParameter(value: String val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let src = value.array()
        src.copy_to(c, 0, 0, src.size())
        c
    fun _visitQueryParameter(value: U64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        c.push((value >> 56).u8())
        c.push((value >> 48).u8())
        c.push((value >> 40).u8())
        c.push((value >> 32).u8())
        c.push((value >> 24).u8())
        c.push((value >> 16).u8())
        c.push((value >> 8).u8())
        c.push(value.u8())
        c
    fun _visitQueryParameter(value: F64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        _visitQueryParameter(value.bits(), c)
        c
    fun _visitQueryParameter(value: I64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        _visitQueryParameter(value.u64(), c)
        c
    fun _visitQueryParameter(value: Array[U8 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        c.append(value)
        c
    fun _visitQueryParameter(value: Bool val, c: Array[U8 val] ref): Array[U8 val] ref =>
        if value == true then
            c.push(0x01)
        else
            c.push(0x00)
        end
        c
    fun _visitQueryParameter(value: Date val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let result: U32 val = ((value.timestamp() / 86400) + 2147483648).u32()
        visitUInt(result, c)
        c
    fun _visitQueryParameter(value: (I32 val | U32 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        visitUInt(value.u32(), c)
        c
    fun _visitQueryParameter(value: F32 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitUInt(value.bits(), c)
        c
    fun _visitQueryParameter(value: NetAddress, c: Array[U8 val] ref): Array[U8 val] ref =>
        if value.ip6() then
            visitUInt(value.addr1, c)
            visitUInt(value.addr2, c)
            visitUInt(value.addr3, c)
            visitUInt(value.addr4, c)
        else
            c.push(value.addr.u8())
            c.push((value.addr >> 8).u8())
            c.push((value.addr >> 16).u8())
            c.push((value.addr >> 24).u8())
        end
        c
    fun _visitQueryParameter(value: (I16 val | U16 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        visitShort(value.u16(), c)
        c
    fun _visitQueryParameter(value: Time val, c: Array[U8 val] ref): Array[U8 val] ref =>
        _visitQueryParameter(value.nanos(), c)
        c
    fun _visitQueryParameter(value: (U8 val | I8 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        c.push(value.u8())
        c
    fun _visitQueryParameter(value: Seq[cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[I64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[F64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[I32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[F32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[I16 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Set[I8 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for subvalue in value.values() do
            visitQueryParameter(subvalue, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[String val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[I64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[F64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[F32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[I32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[I16 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    fun _visitQueryParameter(value: collection.Map[I8 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(value.size().i32(), c)
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, c)
            _visitQueryParameter(v, c)
        end
        c
    
    fun visitUInt(value: U32 val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c.push((value >> 24).u8())
        c.push((value >> 16).u8())
        c.push((value >> 8).u8())
        c.push(value.u8())
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

    fun visitLongString(data: String val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitInt(data.size().i32(), c)
        for byte in data.array().values() do
            c.push(byte)
        end
        c

    fun visitStringList(data: Array[String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitShort(data.size().u16(), c)
        for value in data.values() do
            visitString(value, c)
        end
        c
        
    fun visitStringMap(data: collection.Map[String val, String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitShort(data.size().u16(), c)
        for pairs in data.pairs() do
            visitString(pairs._1, c)
            visitString(pairs._2, c)
        end
        c
    
    // fun visitASCII(data: )
    

