primitive ReadyResponseVisitor is Visitor[ReadyResponse val]

    fun box apply(res: ReadyResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        c
