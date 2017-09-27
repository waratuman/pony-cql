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

    fun box apply(r: RowsResultResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let global_tables_spec: ((String val, String val) | None) = None
        let has_more_pages = false
        let metadata = true

        let column_count: I32 = if r.rows.size() > 0 then
            try
                r.rows(0)?.size().i32()
            else
                0
            end
        else
            0
        end
        
        c
