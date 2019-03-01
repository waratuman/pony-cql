use "chrono"

primitive ResultResponseVisitor is Visitor[ResultResponse]

    fun box apply(r': ResultResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match r'
        | let r: VoidResultResponse val =>
            IntVisitor(0x0001, c)
            VoidResultResponseVisitor(r, c)
        | let r: RowsResultResponse val =>
            IntVisitor(0x0002, c)
            RowsResultResponseVisitor(r, c)
        // | let r: SetKeyspaceResultResponse val =>
        //     IntVisitor(0x0003, c)
        //     SetKeyspaceResponseVisitor(r, c)
        // | let r: PreparedResultResponse val =>
        //     IntVisitor(0x0004, c)
        //     PreparedResponseVisitor(r, c)
        // | let r: SchemaChangeResultResponse val =>
        //     IntVisitor(0x0005, c)
        //     SchemaChangeResponseVisitor(r, c)
        end
        c
        


primitive VoidResultResponseVisitor is Visitor[VoidResultResponse]

    fun box apply(r: VoidResultResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        c


primitive RowsResultResponseVisitor is Visitor[RowsResultResponse]

    fun box apply(
        r: RowsResultResponse val,
        c: Array[U8 val] ref = Array[U8 val])
        : Array[U8 val] ref
    =>
        var global_tables_spec: ((String val, String val) | None) =
            try
                let colspec = r.columns(0)?
                (colspec._1, colspec._2)
            else
                None
            end

        for colspec in r.columns.values() do
            match global_tables_spec
            | (let a: String val, let b: String val) =>
                if (a != colspec._1) and (b != colspec._2) then
                    global_tables_spec = None
                    break
                end
            end
        end

        let metadata = true

        var flags: I32 = 0

        match global_tables_spec
        | (let _: String val, let _: String val) =>
            flags = flags and 0x0001
        end

        match r.paging_state
        | let ps: Array[U8 val] val =>
            flags = flags and 0x0002
        end

        if not metadata then
            flags = flags and 0x0004
        end

        IntVisitor(flags, c)
        IntVisitor(r.columns.size().i32(), c)
        
        match r.paging_state
        | let ps: Array[U8 val] val =>
            BytesVisitor(ps, c)
        end

        match global_tables_spec
        | (let keyspace: String val, let table: String val) =>
            StringVisitor(keyspace, c)
            StringVisitor(table, c)
        end

        for col in r.columns.values() do
            match global_tables_spec
            | None =>
                StringVisitor(col._1, c)
                StringVisitor(col._2, c)
            end
            StringVisitor(col._3, c)
            ShortVisitor(col._4, c)

            // TODO: Visit the subtypes
            // match col._4
            // | 0x0000 => // Custom Type
            // | 0x0020 => // List Type
            // | 0x0021 => // Map Type
            // | 0x0022 => // Set Type
            // | 0x0030 => // UDT Type
            // | 0x0031 => // Tuple
            // end
        end

        IntVisitor(r.rows.size().i32(), c)

        for row in r.rows.values() do
            for col in row.values() do
                var rowValue : Array[U8 val] ref = match col
                // TODO: Custom Type (0x0000)
                | None => BytesVisitor(None)
                | let v : String val => StringVisitor(v)
                | let v : I64 val => LongVisitor(v)
                | let v : Array[U8 val] val => BytesVisitor(v)
                | let v : Bool => BoolVisitor(v)
                | let v : Date val => IntVisitor(v.timestamp().i32())
                | let v : F64 val => DoubleVisitor(v)
                | let v : F32 val => FloatVisitor(v)
                | let v : Time val => LongVisitor(v.u64().i64())
                else
                    []
                end

                BytesVisitor(rowValue, c)
            end
        end
        // visit rows content

        c

// 0x0006    Decimal
// 0x0007    Double
// 0x0008    Float
// 0x0009    Int
// 0x000B    Timestamp
// 0x000C    Uuid
// 0x000D    Varchar
// 0x000E    Varint
// 0x000F    Timeuuid
// 0x0010    Inet
// 0x0011    Date
// 0x0012    Time
// 0x0013    Smallint
// 0x0014    Tinyint
// 0x0015    Duration
// 0x0020    List: the value is an [option], representing the type
//                 of the elements of the list.
// 0x0021    Map: the value is two [option], representing the types of the
//                 keys and values of the map
// 0x0022    Set: the value is an [option], representing the type
//                 of the elements of the set
// 0x0030    UDT: the value is <ks><udt_name><n><name_1><type_1>...<name_n><type_n>
//                 where:
//                     - <ks> is a [string] representing the keyspace name this
//                     UDT is part of.
//                     - <udt_name> is a [string] representing the UDT name.
//                     - <n> is a [short] representing the number of fields of
//                     the UDT, and thus the number of <name_i><type_i> pairs
//                     following
//                     - <name_i> is a [string] representing the name of the
//                     i_th field of the UDT.
//                     - <type_i> is an [option] representing the type of the
//                     i_th field of the UDT.
// 0x0031    Tuple: the value is <n><type_1>...<type_n> where <n> is a [short]
//                     representing the number of values in the type, and <type_i>
//                     are [option] representing the type of the i_th component
//                     of the tuple