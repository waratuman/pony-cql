primitive SupportedResponseVisitor is Visitor[SupportedResponse val]

    fun box apply(res: SupportedResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(2, c)
        StringVisitor("COMPRESSION", c)
        StringListVisitor(res.compression, c)
        StringVisitor("CQL_VERSION", c)
        StringListVisitor(res.cql_version, c)
        c
