primitive ErrorResponseVisitor is Visitor[ErrorResponse val]

    fun box apply(res: ErrorResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        IntVisitor(res.code, c)
        StringVisitor(res.message, c)
        c
