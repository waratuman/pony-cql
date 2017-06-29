primitive AuthResponseRequestVisitor is Visitor[AuthResponseRequest val]

    fun box apply(req: AuthResponseRequest val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        BytesVisitor(req.token, c)
        c
