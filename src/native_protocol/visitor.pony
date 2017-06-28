use "net"
use "chrono"
use cql = "../cql"
use collections = "collections"

interface Visitor[A]

    fun box apply(obj: A, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref


primitive ByteVisitor is Visitor[U8 val]

    fun box apply(value: U8 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push(value)
        collector


primitive UIntVisitor is Visitor[U32 val]
    """
    A 4 byte unsigned integer.
    """

    fun box apply(value: U32 box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive IntVisitor is Visitor[I32 val]
    """
    A 4 byte signed integer.
    """

    fun box apply(value: I32 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive LongVisitor is Visitor[I64 val]
    """
    A 8 byte signed integer.
    """

    fun box apply(value: I64 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 56).u8())
        collector.push((value >> 48).u8())
        collector.push((value >> 40).u8())
        collector.push((value >> 32).u8())
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 08).u8())
        collector.push(value.u8())
        collector


primitive ShortVisitor is Visitor[U16 val]
    """
    A 2 byte unsigned integer.
    """

    fun box apply(value: U16 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive StringVisitor is Visitor[String]
    """
    A short, n, followed by a n byte UTF-8 string.
    """

    fun box apply(value: String val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for byte in value.array().values() do
            ByteVisitor(byte, collector)
        end
        collector


primitive LongStringVisitor is Visitor[String]
    """
    An int, n, followed by a n byte UTF-8 string.
    """

    fun box apply(value: String val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        IntVisitor(value.size().i32(), collector)
        for byte in value.array().values() do
            ByteVisitor(byte, collector)
        end
        collector


primitive UUIDVisitor is Visitor[Seq[U8 val]]
    """
    A 16 byte long uuid.
    """
    
    fun box apply(uuid: Seq[U8 val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        var length: USize = 0
        for byte in uuid.values() do
            ByteVisitor(byte)
        end
        collector


primitive StringListVisitor is Visitor[Array[String val]]
    """
    A short, n, followed by n strings.
    """

    fun box apply(value: Array[String val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for s in value.values() do
            StringVisitor(s, collector)
        end
        collector


primitive BytesVisitor is Visitor[(Seq[U8 val] | None)]
    """
    An int, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(value: (Seq[U8 val] box | None), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | None => IntVisitor(-1, collector)
        | let v: Seq[U8 val] box =>
            IntVisitor(v.size().i32(), collector)
            for byte in v.values() do
                collector.push(byte)
            end
        end
        collector


primitive ValueVisitor is Visitor[(Seq[U8 val] ref | None)]
    """
    An int, n, followed by n bytes. If n == -1 the value None is returned.
    The docs mention n == -2 meaning not set. This is not implemented yet.
    If n < -2 an error is thrown.
    """

    fun box apply(value: (Seq[U8 val] box | None), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | None => IntVisitor(-1, collector)
        | let v: Seq[U8 val] box =>
            IntVisitor(v.size().i32(), collector)
            for byte in v.values() do
                collector.push(byte)
            end
        end
        collector


primitive ShortBytesVisitor is Visitor[Seq[U8 val] ref]
    """
    A short, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(value: Seq[U8 val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for byte in value.values() do
            collector.push(byte)
        end
        collector


primitive InetVisitor is Visitor[cql.Inet ref]
    """
    An address (ip and port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)),
    following by an int representing the port.
    """

    fun box apply(value: cql.Inet ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value.host
        | let h: U32 box =>
            ByteVisitor(4, collector)
            UIntVisitor(h, collector)
        | let h: U128 box =>
            ByteVisitor(16, collector)
            LongVisitor((h >> 64).i64(), collector)
            LongVisitor(h.i64(), collector)
        end

        UIntVisitor(value.port, collector)
        collector


primitive InetAddrVisitor is Visitor[(U32 val | U128 val)]
    """
    An IP address (without port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)).
    """

    fun box apply(value: (U32 box | U128 box), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | let h: U32 box =>
            ByteVisitor(4, collector)
            UIntVisitor(h, collector)
        | let h: U128 box =>
            ByteVisitor(16, collector)
            LongVisitor((h >> 64).i64(), collector)
            LongVisitor(h.i64(), collector)
        end
        collector


primitive ConsistencyVisitor is Visitor[Consistency val]
    """
    A consistency level specification. This is a short.
    """

    fun box apply(value: Consistency, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push(0x00)
        collector.push(match value
        | AnyConsistency => 0x00
        | One => 0x01
        | Two => 0x02
        | Three => 0x03
        | Quorum => 0x04
        | All => 0x05
        | LocalQuorum => 0x06
        | EachQuorum => 0x07
        | Serial => 0x08
        | LocalSerial => 0x09
        | LocalOne => 0x0A
        else 0x00
        end)
        collector


primitive StringMapVisitor is Visitor[collections.Map[String val, String val]]
    """
    A short, n, followed by n pair <k><v> where <k> and <v>
    are a string.
    """
    
    fun box apply(map: collections.Map[String val, String val] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            StringVisitor(value, collector)
        end
        collector


primitive StringMultiMapVisitor is Visitor[collections.Map[String val, Array[String val] ref]]
    """
    A short, n, followed by n pair <k><v> where <k> is a
    string and <v> is a take_string_list.
    """

    fun box apply(map: collections.Map[String val, Array[String val] ref] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            StringListVisitor(value, collector)
        end
        collector


primitive BytesMapVisitor is Visitor[collections.Map[String val, (Array[U8 val] ref | None val)]]
    """
    A short, n, followed by n pair <k><v> where <k> is a string and <v>
    is a bytes.
    """
    
    fun box apply(map: collections.Map[String val, (Array[U8 val] ref | None val)] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            BytesVisitor(value, collector)
        end
        collector


primitive OldVisitor
    
    fun visitOptionsRequest(request: OptionsRequest val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitAuthResponseRequest(request: AuthResponseRequest val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        visitBytes(request.token, c)
        c

    fun visitQueryRequest(request: QueryRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        visitLongString(request.query, c)
        visitConsistency(request.consistency, c)

        var flag: QueryFlags ref = QueryFlags
        let tail: Array[U8 val] ref = Array[U8 val]

        match request.binding
        | let p: Array[QueryParameter val] val =>
            flag.set(Values)
            visitShort(p.size().u16(), tail)
            for value in p.values() do
                visitQueryParameter(value, tail)
            end
        end
        
        if (not request.metadata) then
            flag.set(SkipMetadata)
        end

        match request.page_size
        | let v: I32 =>
            flag.set(PageSize)
            visitInt(v, tail)
        end

        match request.paging_state
        | let v: Array[U8 val] val =>
            flag.set(WithPagingState)
            visitBytes(v, tail)
        end

        match request.serial_consistency
        | let v: Serial val =>
            flag.set(WithSerialConsistency)
            visitConsistency(v, tail)
        | let v: LocalSerial val =>
            flag.set(WithSerialConsistency)
            visitConsistency(v, tail)
        end
    
        match request.timestamp
        | let v: I64 val =>
            flag.set(WithDefaultTimestamp)
            visitLong(v, tail)
        end

        c.push(flag.value())
        c.append(tail)
        c

    // fun visitResultResponse(respons: ResultResponse val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
    //     c

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
        visitShort(consistency.value(), c)
        c
    
    fun visitNone(data: None val, c: Array[U8 val] ref = Array[U8 val]()): Array[U8 val] ref =>
        c

    fun visitQueryParameter(parameter: QueryParameter val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        _visitQueryParameter(parameter, c)
        c
    fun _visitQueryParameter(value: None val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        visitInt(-1, c)
        c
    fun _visitQueryParameter(value: String val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let v = value.array()
        visitInt(value.size().i32(), c)
        for byte in value.values() do
            c.push(byte)
        end
        c
    fun _visitQueryParameter(value: U64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(8, c)
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
        visitInt(value.size().i32(), c)
        c.append(value)
        c
    fun _visitQueryParameter(value: Bool val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(1, c)
        if value == true then
            c.push(0x01)
        else
            c.push(0x00)
        end
        c
    fun _visitQueryParameter(value: Date val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let result: U32 val = ((value.timestamp() / 86400) + 2147483648).u32()
        visitInt(4, c)
        visitUInt(result, c)
        c
    fun _visitQueryParameter(value: (I32 val | U32 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(4, c)
        visitUInt(value.u32(), c)
        c
    fun _visitQueryParameter(value: F32 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(4, c)
        visitUInt(value.bits(), c)
        c
    fun _visitQueryParameter(value: NetAddress, c: Array[U8 val] ref): Array[U8 val] ref =>
        if value.ip6() then
            visitInt(16, c)
            visitUInt(value.addr1, c)
            visitUInt(value.addr2, c)
            visitUInt(value.addr3, c)
            visitUInt(value.addr4, c)
        else
            visitInt(4, c)
            c.push(value.addr.u8())
            c.push((value.addr >> 8).u8())
            c.push((value.addr >> 16).u8())
            c.push((value.addr >> 24).u8())
        end
        c
    fun _visitQueryParameter(value: (I16 val | U16 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(2, c)
        visitShort(value.u16(), c)
        c
    fun _visitQueryParameter(value: Time val, c: Array[U8 val] ref): Array[U8 val] ref =>
        _visitQueryParameter(value.u64(), c)
        c
    fun _visitQueryParameter(value: (U8 val | I8 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        visitInt(1, c)
        c.push(value.u8())
        c
    fun _visitQueryParameter(value: Seq[cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[I64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[F64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[I32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[F32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[I16 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Set[I8 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for subvalue in value.values() do
            visitQueryParameter(subvalue, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[String val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[I64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[F64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[F32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[I32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[I16 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
        c
    fun _visitQueryParameter(value: collections.Map[I8 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = visitInt(value.size().i32())
        for (k, v) in value.pairs() do
            _visitQueryParameter(k, tail)
            _visitQueryParameter(v, tail)
        end
        visitInt(tail.size().i32(), c)
        c.append(tail)
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

    fun visitLong(value: I64 val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        c.push((value >> 56).u8())
        c.push((value >> 48).u8())
        c.push((value >> 40).u8())
        c.push((value >> 32).u8())
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
        
    fun visitStringMap(data: collections.Map[String val, String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visitShort(data.size().u16(), c)
        for pairs in data.pairs() do
            visitString(pairs._1, c)
            visitString(pairs._2, c)
        end
        c
