primitive StartupRequestVisitor is Visitor[StartupRequest val]

    fun box apply(req: StartupRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let compression = req.compression
        let cql_version = req.cql_version
    
        let pairs: U16 = if compression is None then
            1
        else
            2
        end

        ShortVisitor(pairs, c)

        match compression
        | let compression': String => 
            StringVisitor("COMPRESSION", c)
            StringVisitor(compression', c)
        end

        StringVisitor("CQL_VERSION", c)
        StringVisitor(cql_version, c)

        c
