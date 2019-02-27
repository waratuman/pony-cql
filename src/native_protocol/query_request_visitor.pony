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
    
    fun visit
        ( value: ( None val
               | String val
               | U64 val
               | F64 val
               | I64 val
               | Array[U8 val] val
               | Bool val
               | Date val
               | I32 val
               | U32 val
               | F32 val
               | NetAddress val
               | I16 val
               | U16 val
               | Time val
               | U8 val
               | I8 val
               | Seq[cql.NativeType val] val
               | collections.Set[String val] val
               | collections.Set[I64 val] val
               | collections.Set[F64 val] val
               | collections.Set[I32 val] val
               | collections.Set[F32 val] val
               | collections.Set[I16 val] val
               | collections.Set[I8 val] val
               | collections.Map[String val, cql.NativeType val] val
               | collections.Map[I64 val, cql.NativeType val] val
               | collections.Map[F64 val, cql.NativeType val] val
               | collections.Map[I32 val, cql.NativeType val] val
               | collections.Map[F32 val, cql.NativeType val] val
               | collections.Map[I16 val, cql.NativeType val] val
               | collections.Map[I8 val, cql.NativeType val] val
               )
        , c: Array[U8 val] ref = Array[U8 val]
        )
        : Array[U8 val] ref =>
        match value
        | let v : None => IntVisitor(-1, c)
        | let stringValue : String =>
            let v = stringValue.array()
            IntVisitor(v.size().i32(), c)
            for byte in v.values() do
                c.push(byte)
            end
        | let v : U64 val =>
            IntVisitor(8, c)
            c.push((v >> 56).u8())
            c.push((v >> 48).u8())
            c.push((v >> 40).u8())
            c.push((v >> 32).u8())
            c.push((v >> 24).u8())
            c.push((v >> 16).u8())
            c.push((v >> 8).u8())
            c.push(v.u8())
        | let v : F64 val =>
            visit(v.bits(), c)
        | let v : I64 val =>
            visit(v.u64(), c)
        | let v : Array[U8 val] val =>
            IntVisitor(v.size().i32(), c)
            c.append(v)
        | let v : Bool val =>
            IntVisitor(1, c)
            if v == true then
                c.push(0x01)
            else
                c.push(0x00)
            end
        | let v : Date val =>
            let result: U32 val = ((v.timestamp() / 86400) + 2147483648).u32()
            IntVisitor(4, c)
            UIntVisitor(result, c)
        | let v : (I32 val | U32 val) =>
            IntVisitor(4, c)
            UIntVisitor(v.u32(), c)
        | let v : F32 val =>
            IntVisitor(4, c)
            UIntVisitor(v.bits(), c)
        | let v : NetAddress val =>
            if v.ip6() then
                IntVisitor(16, c)
                var ip6 = v.ipv6_addr()

                UIntVisitor(ip6._1, c)
                UIntVisitor(ip6._2, c)
                UIntVisitor(ip6._3, c)
                UIntVisitor(ip6._4, c)
            else
                IntVisitor(4, c)
                UIntVisitor(v.ipv4_addr(), c)
            end
        | let v : (I16 val | U16 val) =>
            IntVisitor(2, c)
            ShortVisitor(v.u16(), c)
        | let v : Time val =>
            visit(v.u64(), c)
        | let v : (U8 val | I8 val) =>
            IntVisitor(1, c)
            c.push(v.u8())
        | let v :  Seq[cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[String val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[I64 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[F64 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[I32 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[F32 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[I16 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Set[I8 val] val =>
            let tail : Array[U8 val] ref = IntVisitor(v.size().i32())
            for subvalue in v.values() do
                QueryRequestParameterVisitor(subvalue, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[String val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[I64 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[F64 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[I32 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[F32 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[I16 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        | let v : collections.Map[I8 val, cql.NativeType val] val =>
            let tail = IntVisitor(v.size().i32())
            for (k, va) in v.pairs() do
                visit(k, tail)
                visit(va, tail)
            end
            IntVisitor(tail.size().i32(), c)
            c.append(tail)
        end
        c
