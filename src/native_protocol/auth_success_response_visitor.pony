primitive AuthSuccessResponseVisitor is Visitor[AuthSuccessResponse val]

    fun box apply(res: AuthSuccessResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        BytesVisitor(res.token, c)
        c
