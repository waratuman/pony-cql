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
            // visit the option type
        end

        IntVisitor(r.rows.size().i32(), c)
        // visit rows content

        c
