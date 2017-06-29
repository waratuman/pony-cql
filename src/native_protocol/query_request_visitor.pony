use "chrono"
use "net"
use cql = "../cql"
use collections = "collections"

primitive QueryRequestVisitor is Visitor[QueryRequest val]

    fun box apply(req: QueryRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        LongStringVisitor(req.query, c)
        ConsistencyVisitor(req.consistency, c)
        
        var flag: QueryFlags ref = QueryFlags
        let tail: Array[U8 val] ref = Array[U8 val]

        match req.binding
        | let p: Array[QueryParameter val] val =>
            flag.set(Values)
            ShortVisitor(p.size().u16(), tail)
            for value in p.values() do
                QueryRequestParameterVisitor(value, tail)
            end
        end
        
        if (not req.metadata) then
            flag.set(SkipMetadata)
        end

        match req.page_size
        | let v: I32 =>
            flag.set(PageSize)
            IntVisitor(v, tail)
        end

        match req.paging_state
        | let v: Array[U8 val] val =>
            flag.set(WithPagingState)
            BytesVisitor(v, tail)
        end

        match req.serial_consistency
        | let v: Serial val =>
            flag.set(WithSerialConsistency)
            ConsistencyVisitor(v, tail)
        | let v: LocalSerial val =>
            flag.set(WithSerialConsistency)
            ConsistencyVisitor(v, tail)
        end
    
        match req.timestamp
        | let v: I64 val =>
            flag.set(WithDefaultTimestamp)
            LongVisitor(v, tail)
        end

        c.push(flag.value())
        c.append(tail)

        c


primitive QueryRequestParameterVisitor is Visitor[QueryParameter]

    fun box apply(param: QueryParameter val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        visit(param, c)
        c
    
    fun visit(value: None val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        IntVisitor(-1, c)
        c

    fun visit(value: String val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let v = value.array()
        IntVisitor(value.size().i32(), c)
        for byte in value.values() do
            c.push(byte)
        end
        c
    
    fun visit(value: U64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(8, c)
        c.push((value >> 56).u8())
        c.push((value >> 48).u8())
        c.push((value >> 40).u8())
        c.push((value >> 32).u8())
        c.push((value >> 24).u8())
        c.push((value >> 16).u8())
        c.push((value >> 8).u8())
        c.push(value.u8())
        c
    
    fun visit(value: F64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visit(value.bits(), c)
        c
    
    fun visit(value: I64 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visit(value.u64(), c)
        c
    
    fun visit(value: Array[U8 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(value.size().i32(), c)
        c.append(value)
        c
    
    fun visit(value: Bool val, c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(1, c)
        if value == true then
            c.push(0x01)
        else
            c.push(0x00)
        end
        c
    
    fun visit(value: Date val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let result: U32 val = ((value.timestamp() / 86400) + 2147483648).u32()
        IntVisitor(4, c)
        UIntVisitor(result, c)
        c
    
    fun visit(value: (I32 val | U32 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(4, c)
        UIntVisitor(value.u32(), c)
        c
    
    fun visit(value: F32 val, c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(4, c)
        UIntVisitor(value.bits(), c)
        c
    
    fun visit(value: NetAddress, c: Array[U8 val] ref): Array[U8 val] ref =>
        if value.ip6() then
            IntVisitor(16, c)
            UIntVisitor(value.addr1, c)
            UIntVisitor(value.addr2, c)
            UIntVisitor(value.addr3, c)
            UIntVisitor(value.addr4, c)
        else
            IntVisitor(4, c)
            c.push(value.addr.u8())
            c.push((value.addr >> 8).u8())
            c.push((value.addr >> 16).u8())
            c.push((value.addr >> 24).u8())
        end
        c
    
    fun visit(value: (I16 val | U16 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(2, c)
        ShortVisitor(value.u16(), c)
        c
    
    fun visit(value: Time val, c: Array[U8 val] ref): Array[U8 val] ref =>
        visit(value.u64(), c)
        c
    
    fun visit(value: (U8 val | I8 val), c: Array[U8 val] ref): Array[U8 val] ref =>
        IntVisitor(1, c)
        c.push(value.u8())
        c
    
    fun visit(value: Seq[cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c
    
    fun visit(value: collections.Set[String val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    
    fun visit(value: collections.Set[I64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Set[F64 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Set[I32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Set[F32 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Set[I16 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Set[I8 val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for subvalue in value.values() do
            QueryRequestParameterVisitor(subvalue, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[String val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[I64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[F64 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[F32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[I32 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[I16 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c

    fun visit(value: collections.Map[I8 val, cql.NativeType val] val, c: Array[U8 val] ref): Array[U8 val] ref =>
        let tail = IntVisitor(value.size().i32())
        for (k, v) in value.pairs() do
            visit(k, tail)
            visit(v, tail)
        end
        IntVisitor(tail.size().i32(), c)
        c.append(tail)
        c
