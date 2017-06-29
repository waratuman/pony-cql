primitive OptionsRequestVisitor is Visitor[OptionsRequest val]

    fun box apply(req: OptionsRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        c
